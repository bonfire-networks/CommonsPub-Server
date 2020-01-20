defmodule MoodleNet.ActivityPub.PublisherTest do
  use MoodleNet.DataCase
  import MoodleNet.Test.Faking
  import ActivityPub.Factory
  alias MoodleNet.ActivityPub.Publisher
  alias MoodleNet.Follows

  describe "comments" do
    test "it federates a comment that's threaded on an actor" do
      actor = fake_user!()
      commented_actor = fake_user!()
      thread = fake_thread!(actor, commented_actor)
      comment = fake_comment!(actor, thread)

      assert {:ok, activity} = Publisher.comment(comment)
      assert activity.object.mn_pointer_id == comment.id
      assert activity.local == true
      assert activity.object.local == true
      {:ok, actor} = ActivityPub.Actor.get_by_username(commented_actor.actor.preferred_username)
      assert activity.data["context"] == actor.ap_id
    end

    test "it federates a reply to a comment" do
      actor = fake_user!()
      commented_actor = fake_user!()
      thread = fake_thread!(actor, commented_actor, %{is_local: true})
      comment = fake_comment!(actor, thread)
      # Publish the comment first so we can reply to it
      Publisher.comment(comment)

      {:ok, reply} =
        MoodleNet.Threads.Comments.create_reply(actor, thread, comment, %{
          content: "test",
          is_local: true
        })

      assert {:ok, activity} = Publisher.comment(reply)
      assert activity.object.data["inReplyTo"]
    end

    test "it deletes a comment" do
      actor = fake_user!()
      commented_actor = fake_user!()
      thread = fake_thread!(actor, commented_actor, %{is_local: true})
      comment = fake_comment!(actor, thread)
      # Publish the comment first so we can delete it
      Publisher.comment(comment)

      assert {:ok, activity} = Publisher.delete_comment_or_resource(comment)
    end
  end

  describe "creating resources" do
    test "it federates a resource" do
      actor = fake_user!()
      community = fake_community!(actor)
      collection = fake_collection!(actor, community)
      resource = fake_resource!(actor, collection)

      assert {:ok, activity} = Publisher.create_resource(resource)
      assert activity.object.mn_pointer_id == resource.id
      assert activity.local == true
      assert activity.object.local == true
      {:ok, collection} = ActivityPub.Actor.get_by_local_id(collection.id)
      {:ok, actor} = ActivityPub.Actor.get_by_local_id(actor.id)
      assert activity.data["context"] == collection.ap_id
      assert activity.data["actor"] == actor.ap_id
    end

    test "it deletes a resource" do
      actor = fake_user!()
      community = fake_community!(actor)
      collection = fake_collection!(actor, community)
      resource = fake_resource!(actor, collection)
      Publisher.create_resource(resource)

      assert {:ok, activity} = Publisher.delete_comment_or_resource(resource)
    end
  end

  describe "creating actors" do
    test "it federates a create activity for a community" do
      actor = fake_user!()
      community = fake_community!(actor)

      assert {:ok, activity} = Publisher.create_community(community)
      assert activity.data["object"]["type"] == "Group"
      assert activity.data["object"]["id"]
    end

    test "it federate a create activity for a collection" do
      actor = fake_user!()
      community = fake_community!(actor)
      collection = fake_collection!(actor, community)

      assert {:ok, activity} = Publisher.create_collection(collection)
      assert activity.data["object"]["type"] == "Group"
      assert activity.data["object"]["id"]
    end
  end

  describe "follows" do
    test "it federates a follow of a remote actor" do
      follower = fake_user!()
      ap_followed = actor()
      {:ok, followed} = MoodleNet.Users.fetch_any_by_username(ap_followed.username)

      {:ok, follow} =
        MoodleNet.Follows.create(follower, followed, %{
          is_muted: false,
          is_public: true,
          is_local: true
        })

      assert {:ok, activity} = Publisher.follow(follow)
      assert activity.data["to"] == [ap_followed.ap_id]
    end

    test "it federate an unfollow of a remote actor" do
      follower = fake_user!()
      ap_followed = actor()
      {:ok, followed} = MoodleNet.Users.fetch_any_by_username(ap_followed.username)

      {:ok, follow} =
        MoodleNet.Follows.create(follower, followed, %{
          is_muted: false,
          is_public: true,
          is_local: true
        })

      {:ok, follow_activity} = Publisher.follow(follow)
      {:ok, unfollow} = Follows.undo(follow)

      assert {:ok, unfollow_activity} = Publisher.unfollow(unfollow)
      assert unfollow_activity.data["object"]["id"] == follow_activity.data["id"]
    end

    test "it errors when remote account manually approves followers" do
      follower = fake_user!()
      ap_followed = actor(%{data: %{"manuallyApprovesFollowers" => true}})
      {:ok, followed} = MoodleNet.Users.fetch_any_by_username(ap_followed.username)

      {:ok, follow} =
        MoodleNet.Follows.create(follower, followed, %{
          is_muted: false,
          is_public: true,
          is_local: true
        })

      assert {:error, "account is private"} = Publisher.follow(follow)
    end
  end

  describe "blocks" do
    test "it federates a block of a remote actor" do
      blocker = fake_user!()
      ap_blocked = actor()
      {:ok, blocked} = MoodleNet.Users.fetch_any_by_username(ap_blocked.username)

      {:ok, block} =
        MoodleNet.Blocks.create(blocker, blocked, %{
          is_muted: false,
          is_public: true,
          is_blocked: false,
          is_local: true
        })

      assert {:ok, activity} = Publisher.block(block)
      assert activity.data["to"] == [ap_blocked.ap_id]
    end

    test "it federate an unblock of a remote actor" do
      blocker = fake_user!()
      ap_blocked = actor()
      {:ok, blocked} = MoodleNet.Users.fetch_any_by_username(ap_blocked.username)

      {:ok, block} =
        MoodleNet.Blocks.create(blocker, blocked, %{
          is_muted: false,
          is_public: true,
          is_blocked: false,
          is_local: true
        })

      {:ok, block_activity} = Publisher.block(block)
      {:ok, unblock} = MoodleNet.Blocks.delete(block)

      assert {:ok, unblock_activity} = Publisher.unblock(unblock)
      assert unblock_activity.data["object"]["id"] == block_activity.data["id"]
    end
  end

  describe "flags" do
    test "it flags an actor" do
      flagger = fake_user!()
      ap_flagged = actor()
      {:ok, flagged} = MoodleNet.ActivityPub.Adapter.get_actor_by_username(ap_flagged.username)

      {:ok, flag} =
        MoodleNet.Flags.create(flagger, flagged, %{
          message: "blocked AND reported!!!",
          is_local: true
        })

      assert {:ok, activity} = Publisher.flag(flag)
    end

    test "it flages a community" do
      flagger = fake_user!()
      ap_flagged = community()
      {:ok, flagged} = MoodleNet.ActivityPub.Adapter.get_actor_by_username(ap_flagged.username)

      {:ok, flag} =
        MoodleNet.Flags.create(flagger, flagged, %{
          message: "blocked AND reported!!!",
          is_local: true
        })

      assert {:ok, activity} = Publisher.flag(flag)
    end

    test "it flags a collection" do
      flagger = fake_user!()
      ap_flagged = collection()
      {:ok, flagged} = MoodleNet.ActivityPub.Adapter.get_actor_by_username(ap_flagged.username)

      {:ok, flag} =
        MoodleNet.Flags.create(flagger, flagged, %{
          message: "blocked AND reported!!!",
          is_local: true
        })

      assert {:ok, activity} = Publisher.flag(flag)
    end

    test "if flags a comment" do
      actor = fake_user!()
      commented_actor = fake_user!()
      thread = fake_thread!(actor, commented_actor)
      comment = fake_comment!(actor, thread)
      # Comment needs to be published before the flag can be federated
      Publisher.comment(comment)

      {:ok, flag} =
        MoodleNet.Flags.create(commented_actor, comment, %{
          message: "blocked AND reported!!!",
          is_local: true
        })

      assert {:ok, activity} = Publisher.flag(flag)
    end

    test "it flags a resource" do
      actor = fake_user!()
      community = fake_community!(actor)
      collection = fake_collection!(actor, community)
      resource = fake_resource!(actor, collection)
      flag_actor = fake_user!()
      Publisher.create_resource(resource)

      {:ok, flag} =
        MoodleNet.Flags.create(flag_actor, resource, %{
          message: "blocked AND reported!!!",
          is_local: true
        })

      assert {:ok, activity} = Publisher.flag(flag)
    end
  end

  describe "likes" do
    test "it likes a comment" do
      actor = fake_user!()
      commented_actor = fake_user!()
      thread = fake_thread!(actor, commented_actor)
      comment = fake_comment!(actor, thread)
      # Comment needs to be published before it can be liked
      Publisher.comment(comment)

      {:ok, like} =
        MoodleNet.Likes.create(commented_actor, comment, %{is_public: true, is_local: true})

      assert {:ok, like_activity, object} = Publisher.like(like)
      assert like_activity.data["object"] == object.data["id"]
    end

    test "it unlikes a comment" do
      actor = fake_user!()
      commented_actor = fake_user!()
      thread = fake_thread!(actor, commented_actor)
      comment = fake_comment!(actor, thread)
      # Comment needs to be published before it can be liked
      Publisher.comment(comment)

      {:ok, like} =
        MoodleNet.Likes.create(commented_actor, comment, %{is_public: true, is_local: true})

      Publisher.like(like)
      # No context function for unliking
      assert {:ok, unlike_activity, like_activity, object} = Publisher.unlike(like)
      assert like_activity.data["object"] == object.data["id"]
      assert unlike_activity.data["object"] == like_activity.data
    end
  end

  describe "updating actors" do
    test "it works for users" do
      actor = fake_user!()
      assert {:ok, activity} = Publisher.update_actor(actor)
    end

    test "it works for communities" do
      actor = fake_user!() |> fake_community!()
      assert {:ok, activity} = Publisher.update_actor(actor)
    end

    test "it works for collections" do
      user = fake_user!()
      comm = fake_community!(user)
      actor = fake_collection!(user, comm)
      assert {:ok, activity} = Publisher.update_actor(actor)
    end
  end

  describe "deleting actors" do
    test "it works for users" do
      actor = fake_user!()
      assert {:ok, activity} = Publisher.delete_actor(actor)
    end

    test "it works for communities" do
      actor = fake_user!() |> fake_community!()
      assert {:ok, activity} = Publisher.delete_actor(actor)
    end

    test "it works for collections" do
      user = fake_user!()
      comm = fake_community!(user)
      actor = fake_collection!(user, comm)
      assert {:ok, activity} = Publisher.delete_actor(actor)
    end
  end
end
