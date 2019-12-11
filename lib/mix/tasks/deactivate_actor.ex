defmodule Mix.Tasks.MoodleNet.DeactivateActor do
  use Mix.Task
  alias ActivityPub.Actor

  @shortdoc "Deactivate a remote actor, disabling incoming federation from it"

  @usage "mix task moodle_net.deactivate_actor ACTOR_URI"

  @moduledoc """
  This mix task is useful for disabling abusive actors without rejecting their entire instance.
  To reactivate an actor simply run the task for that actor URI again.

  Usage:

    $ #{@usage}
  """

  def start_app do
    Application.put_env(:phoenix, :serve_endpoints, false, persistent: true)
    {:ok, _} = Application.ensure_all_started(:moodle_net)
  end

  defp shell_info(message) do
    if mix_shell?(),
      do: Mix.shell().info(message),
      else: IO.puts(message)
  end

  defp shell_error(message) do
    if mix_shell?(),
      do: Mix.shell().error(message),
      else: IO.puts(:stderr, message)
  end

  defp mix_shell?, do: :erlang.function_exported(Mix, :shell, 0)

  def run([ap_id | _]) do
    start_app()

    with {:ok, actor} <- Actor.get_cached_by_ap_id(ap_id) do
      {:ok, actor_object} = Actor.toggle_active(actor)

      shell_info(
        "Activation status of #{ap_id}: #{if(actor_object.data["deactivated"], do: "de", else: "")}activated"
      )
    else
      _ ->
        shell_error("No actor #{ap_id}")
    end
  end
end
