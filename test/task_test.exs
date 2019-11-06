defmodule Mix.Tasks.MoodleNet.DeactivateActorTest do
  use MoodleNet.DataCase

  alias ActivityPub.Actor

  import ActivityPub.Factory

  setup_all do
    Mix.shell(Mix.Shell.Process)

    on_exit(fn ->
      Mix.shell(Mix.Shell.IO)
    end)

    :ok
  end


  describe "running toggle_activated" do
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

      Mix.Tasks.MoodleNet.DeactivateActor.run([actor.ap_id])

      assert_received {:mix_shell, :info, [message]}
      assert message =~ " activated"

      {:ok, actor} = Actor.get_by_ap_id(actor.ap_id)
      refute actor.deactivated
    end
  end
end
