defmodule Mix.Tasks.MoodleNet.TaskTest do
  use MoodleNet.DataCase

  alias ActivityPub.Actor

  import MoodleNet.Test.Faking
  import ActivityPub.Factory

  setup_all do
    Mix.shell(Mix.Shell.Process)

    on_exit(fn ->
      Mix.shell(Mix.Shell.IO)
    end)

    :ok
  end


  describe "running deactivate_actor" do
    test "user is deactivated" do
      actor = actor()

      Mix.Tasks.MoodleNet.DeactivateActor.run([actor.ap_id])

      assert_received {:mix_shell, :info, [message]}
      assert message =~ " deactivated"

      {:ok, actor} = Actor.get_by_ap_id(actor.ap_id)
      assert actor.deactivated
    end

    test "user is activated" do
      actor = actor(%{data: %{"deactivated" => true}})

      Mix.Tasks.MoodleNet.DeactivateActor.run(["undo", actor.ap_id])

      assert_received {:mix_shell, :info, [message]}
      assert message =~ " activated"

      {:ok, actor} = Actor.get_by_ap_id(actor.ap_id)
      refute actor.deactivated
    end
  end


  describe "running update_canonical_urls" do
    test "works" do
      user = fake_user!()
      community = fake_community!(user, %{canonical_url: nil})
      collection = fake_collection!(user, community, %{canonical_url: nil})
      resource = fake_resource!(user, collection, %{canonical_url: nil})

      # Resource needs to be published for its canonical URL to be set
      Oban.drain_queue(:mn_ap_publish)
      Mix.Tasks.MoodleNet.GenerateCanonicalUrls.run([])

      {:ok, community} = MoodleNet.Communities.one([:default, id: community.id])
      assert String.starts_with?(community.actor.canonical_url, "http://localhost:4001/pub/actors/")
      {:ok, collection} = MoodleNet.Collections.one([:default, id: collection.id])
      assert String.starts_with?(collection.actor.canonical_url, "http://localhost:4001/pub/actors/")
      {:ok, resource} = MoodleNet.Resources.one(id: resource.id)
      assert String.starts_with?(resource.canonical_url, "http://localhost:4001/pub/objects")
    end
  end
end
