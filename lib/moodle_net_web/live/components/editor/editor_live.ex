defmodule MoodleNetWeb.EditorLive do
  use MoodleNetWeb, :live_component

  import MoodleNetWeb.Helpers.Common

  def mount(socket) do
    {:ok, assign(socket, :editor, Application.get_env(:moodle_net, :ux)[:editor])}
  end
end
