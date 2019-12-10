defmodule MoodleNet.ActivityPub.AdapterTest do
  import ActivityPub.Factory
  import MoodleNet.Test.Faking
  alias MoodleNet.ActivityPub.Adapter

  use MoodleNet.DataCase

  describe "fetching local actors by id" do
    test "users" do
      user = fake_user!()
      {:ok, actor} = ActivityPub.Actor.get_by_local_id(user.id)
      assert actor.data["type"] == "Person"
      assert actor.username == user.actor.preferred_username
    end

    test "communities" do
      user = fake_user!()
      community = fake_community!(user)
      {:ok, actor} = ActivityPub.Actor.get_by_local_id(community.id)
      assert actor.data["type"] == "MN:Community"
      assert actor.username == community.actor.preferred_username
      assert actor.data["attributedTo"]
    end

    test "collections" do
      user = fake_user!()
      community = fake_community!(user)
      collection = fake_collection!(user, community)
      {:ok, actor} = ActivityPub.Actor.get_by_local_id(collection.id)
      assert actor.data["type"] == "MN:Collection"
      assert actor.username == collection.actor.preferred_username
      assert actor.data["attributedTo"]
      assert actor.data["context"]
    end
  end

  describe "fetching local actors by username" do
    test "users" do
      user = fake_user!()
      {:ok, actor} = ActivityPub.Actor.get_by_username(user.actor.preferred_username)
      assert actor.data["type"] == "Person"
      assert actor.username == user.actor.preferred_username
    end

    test "communities" do
      user = fake_user!()
      community = fake_community!(user)
      {:ok, actor} = ActivityPub.Actor.get_by_username(community.actor.preferred_username)
      assert actor.data["type"] == "MN:Community"
      assert actor.username == community.actor.preferred_username
      assert actor.data["attributedTo"]
    end

    test "collections" do
      user = fake_user!()
      community = fake_community!(user)
      collection = fake_collection!(user, community)
      {:ok, actor} = ActivityPub.Actor.get_by_username(collection.actor.preferred_username)
      assert actor.data["type"] == "MN:Collection"
      assert actor.username == collection.actor.preferred_username
      assert actor.data["attributedTo"]
      assert actor.data["context"]
    end
  end

  describe "creating remote actors" do
    test "creating actors work" do
      actor = insert(:actor)
      host = URI.parse(actor.data["id"]).host
      username = actor.data["preferredUsername"] <> "@" <> host

      {:ok, created_actor} = Adapter.create_remote_actor(actor.data, username)
      assert created_actor.actor.preferred_username == username
    end

    test "pointer insertion into AP table works" do
      actor = insert(:actor)
      host = URI.parse(actor.data["id"]).host
      username = actor.data["preferredUsername"] <> "@" <> host

      {:ok, created_actor} = Adapter.create_remote_actor(actor.data, username)

      %ActivityPub.Object{} = object = ActivityPub.Object.get_by_pointer_id(created_actor.id)

      %MoodleNet.Meta.Pointer{} = MoodleNet.Meta.find!(object.mn_pointer_id)
    end
  end

  describe "handle activity" do
    test "comment on a local actor" do
      actor = actor()
      commented_actor = fake_user!()
      {:ok, ap_commented_actor} = ActivityPub.Actor.get_by_local_id(commented_actor.id)
      note = insert(:note, %{actor: actor, data: %{"context" => ap_commented_actor.data["id"]}})
      note_activity = insert(:note_activity, %{note: note})

      assert :ok = Adapter.perform(:handle_activity, note_activity)
    end

    test "reply to a comment" do
      actor = fake_user!()
      community = fake_user!() |> fake_community!()
      {:ok, thread} = MoodleNet.Comments.create_thread(community, actor, %{is_local: true})

      {:ok, comment} =
        MoodleNet.Comments.create_comment(thread, actor, %{is_local: true, content: "hi"})

      {:ok, activity} = MoodleNet.ActivityPub.Publisher.comment(comment)
      reply_actor = actor()

      object = %{
        "inReplyTo" => activity.object.data["id"],
        "type" => "Note",
        "actor" => reply_actor.ap_id,
        "content" => "hi"
      }

      params = %{
        actor: reply_actor,
        to: ["https://www.w3.org/ns/activitystreams#Public"],
        object: object,
        context: ActivityPub.Utils.generate_context_id(),
        local: false
      }

      {:ok, _activity} = ActivityPub.create(params)
      assert %{success: 1, failure: 0} = Oban.drain_queue(:ap_incoming)
    end

    test "resource" do
      actor = actor()
      collection = collection()

      object = %{
        "name" => "resource",
        "url" => "https://resource.com",
        "actor" => actor.ap_id,
        "attributedTo" => actor.ap_id,
        "context" => collection.ap_id,
        "type" => "Document",
        "tag" => "GPL-v3",
        "summary" => "this is a resource",
        "icon" => "https://icon.store/picture.png"
      }

      params = %{
        actor: actor,
        to: ["https://www.w3.org/ns/activitystreams#Public"],
        object: object,
        context: collection.ap_id,
        additional: %{
          "cc" => [collection.data["followers"], actor.data["followers"]]
        },
        local: false
      }

      {:ok, activity} = ActivityPub.create(params)
      assert %{success: 1, failure: 0} = Oban.drain_queue(:ap_incoming)

      assert {:ok, _} =
               MoodleNet.Repo.fetch_by(MoodleNet.Resources.Resource, %{
                 canonical_url: activity.object.data["id"]
               })
    end

    test "follows" do
      follower = actor()
      followed = fake_user!() |> fake_community!()
      {:ok, ap_followed} = ActivityPub.Actor.get_by_local_id(followed.id)
      {:ok, _} = ActivityPub.follow(follower, ap_followed, nil, false)
      assert %{success: 1, failure: 0} = Oban.drain_queue(:ap_incoming)
      {:ok, follower} = MoodleNet.ActivityPub.Adapter.get_actor_by_ap_id(follower.ap_id)
      assert {:ok, _} = MoodleNet.Common.find_follow(follower, followed)
    end

    test "unfollows" do
      follower = actor()
      followed = fake_user!() |> fake_community!()
      {:ok, ap_followed} = ActivityPub.Actor.get_by_local_id(followed.id)
      {:ok, _} = ActivityPub.follow(follower, ap_followed, nil, false)
      assert %{success: 1, failure: 0} = Oban.drain_queue(:ap_incoming)
      {:ok, _} = ActivityPub.unfollow(follower, ap_followed, nil, false)
      assert %{success: 1, failure: 0} = Oban.drain_queue(:ap_incoming)
      {:ok, follower} = MoodleNet.ActivityPub.Adapter.get_actor_by_ap_id(follower.ap_id)
      assert {:error, _} = MoodleNet.Common.find_follow(follower, followed)
    end

    test "blocks" do
      blocker = actor()
      blocked = fake_user!() |> fake_community!()
      {:ok, ap_blocked} = ActivityPub.Actor.get_by_local_id(blocked.id)
      {:ok, _} = ActivityPub.block(blocker, ap_blocked, nil, false)
      assert %{success: 1, failure: 0} = Oban.drain_queue(:ap_incoming)
      {:ok, blocker} = MoodleNet.ActivityPub.Adapter.get_actor_by_ap_id(blocker.ap_id)
      assert {:ok, _} = MoodleNet.Common.find_block(blocker, blocked)
    end

    test "unblocks" do
      blocker = actor()
      blocked = fake_user!() |> fake_community!()
      {:ok, ap_blocked} = ActivityPub.Actor.get_by_local_id(blocked.id)
      {:ok, _} = ActivityPub.block(blocker, ap_blocked, nil, false)
      assert %{success: 1, failure: 0} = Oban.drain_queue(:ap_incoming)
      {:ok, _} = ActivityPub.unblock(blocker, ap_blocked, nil, false)
      assert %{success: 1, failure: 0} = Oban.drain_queue(:ap_incoming)
      {:ok, blocker} = MoodleNet.ActivityPub.Adapter.get_actor_by_ap_id(blocker.ap_id)
      assert {:error, _} = MoodleNet.Common.find_block(blocker, blocked)
    end

    test "likes" do
      actor = fake_user!()
      commented_actor = fake_user!()
      thread = fake_thread!(actor, commented_actor)
      comment = fake_comment!(actor, thread)
      {:ok, activity} = MoodleNet.ActivityPub.Publisher.comment(comment)
      like_actor = actor()
      {:ok, _, _} = ActivityPub.like(like_actor, activity.object, nil, false)
      assert %{success: 1, failure: 0} = Oban.drain_queue(:ap_incoming)
      {:ok, like_actor} = MoodleNet.ActivityPub.Adapter.get_actor_by_ap_id(like_actor.ap_id)
      assert {:ok, _} = MoodleNet.Common.find_like(like_actor, comment)
    end

    test "flags" do
      actor = fake_user!()
      commented_actor = fake_user!()
      thread = fake_thread!(actor, commented_actor)
      comment = fake_comment!(actor, thread)
      {:ok, activity} = MoodleNet.ActivityPub.Publisher.comment(comment)
      flag_actor = actor()
      {:ok, account} = ActivityPub.Actor.get_by_local_id(actor.id)

      ActivityPub.flag(%{
        actor: flag_actor,
        context: ActivityPub.Utils.generate_context_id(),
        statuses: [activity.object],
        account: account,
        local: false,
        content: "blocked AND reported!!!!"
      })

      assert %{success: 1, failure: 0} = Oban.drain_queue(:ap_incoming)
      {:ok, flag_actor} = Adapter.get_actor_by_ap_id(flag_actor.ap_id)
      assert {:ok, flag} = MoodleNet.Common.find_flag(flag_actor, comment)
    end

    test "flags with multiple comments" do
      actor = fake_user!()
      commented_actor = fake_user!()
      thread = fake_thread!(actor, commented_actor)
      comment_1 = fake_comment!(actor, thread)
      {:ok, activity_1} = MoodleNet.ActivityPub.Publisher.comment(comment_1)
      comment_2 = fake_comment!(actor, thread)
      {:ok, activity_2} = MoodleNet.ActivityPub.Publisher.comment(comment_2)

      flag_actor = actor()
      {:ok, account} = ActivityPub.Actor.get_by_local_id(actor.id)

      ActivityPub.flag(%{
        actor: flag_actor,
        context: ActivityPub.Utils.generate_context_id(),
        statuses: [activity_1.object, activity_2.object],
        account: account,
        local: false,
        content: "blocked AND reported!!!!"
      })

      assert %{success: 1, failure: 0} = Oban.drain_queue(:ap_incoming)
      {:ok, flag_actor} = Adapter.get_actor_by_ap_id(flag_actor.ap_id)
      assert {:ok, flag} = MoodleNet.Common.find_flag(flag_actor, comment_1)
      assert {:ok, flag} = MoodleNet.Common.find_flag(flag_actor, comment_2)
    end

    test "user deletes" do
      actor = actor()
      ActivityPub.delete(actor, false)
      assert %{success: 1, failure: 0} = Oban.drain_queue(:ap_incoming)
      assert {:error, "not found"} = Adapter.get_actor_by_ap_id(actor.ap_id)
    end

    test "community deletes" do
      actor = community()
      ActivityPub.delete(actor, false)
      assert %{success: 1, failure: 0} = Oban.drain_queue(:ap_incoming)
      assert {:error, "not found"} = Adapter.get_actor_by_ap_id(actor.ap_id)
    end

    test "collection deletes" do
      actor = collection()
      ActivityPub.delete(actor, false)
      assert %{success: 1, failure: 0} = Oban.drain_queue(:ap_incoming)
      assert {:error, "not found"} = Adapter.get_actor_by_ap_id(actor.ap_id)
    end

    test "comment deletes" do
      actor = fake_user!()
      commented_actor = fake_user!()
      thread = fake_thread!(actor, commented_actor)
      comment = fake_comment!(actor, thread)
      {:ok, activity} = MoodleNet.ActivityPub.Publisher.comment(comment)
      object = ActivityPub.Object.get_by_ap_id(activity.data["object"])
      ActivityPub.delete(object, false)
      %{success: 1, failure: 0} = Oban.drain_queue(:ap_incoming)
      assert {:error, _} = MoodleNet.Comments.fetch_comment(comment.id)
    end

    test "resource deletes" do
      actor = fake_user!()
      community = fake_community!(actor)
      collection = fake_collection!(actor, community)
      resource = fake_resource!(actor, collection)
      {:ok, activity} = MoodleNet.ActivityPub.Publisher.create_resource(resource)
      object = ActivityPub.Object.get_by_ap_id(activity.data["object"])
      ActivityPub.delete(object, false)
      %{success: 1, failure: 0} = Oban.drain_queue(:ap_incoming)
      assert {:error, _} = MoodleNet.Resources.fetch(resource.id)
    end
  end
end
