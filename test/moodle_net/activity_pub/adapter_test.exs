defmodule MoodleNet.ActivityPub.AdapterTest do
  import ActivityPub.Factory
  alias MoodleNet.ActivityPub.Adapter

  use MoodleNet.DataCase

  describe "creating remote actors" do
    test "creating actors work" do
      actor = insert(:actor)
      host = URI.parse(actor.data["id"]).host
      username = actor.data["preferredUsername"] <> "@" <> host

      {:ok, created_actor} = Adapter.create_remote_actor(actor.data, username)
      assert created_actor.preferred_username == username
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
end
