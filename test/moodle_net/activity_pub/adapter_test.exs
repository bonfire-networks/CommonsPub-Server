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

    test "likes" do
      actor = fake_user!()
      commented_actor = fake_user!()
      thread = fake_thread!(actor, commented_actor)
      comment = fake_comment!(actor, thread)
      {:ok, activity} = MoodleNet.ActivityPub.Publisher.comment(comment)
      like_actor = actor()
      {:ok, like_activity, _} = ActivityPub.like(like_actor, activity.object, nil, false)
      assert :ok == Adapter.perform(:handle_activity, like_activity)
    end
  end
end
