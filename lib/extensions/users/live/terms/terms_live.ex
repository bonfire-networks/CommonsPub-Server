defmodule MoodleNetWeb.TermsLive do
  use MoodleNetWeb, :live_view
  import MoodleNetWeb.Helpers.Common

  def mount(params, session, socket) do
    socket = init_assigns(params, session, socket)

    {:ok,
     socket
     |> assign(app_name: Application.get_env(:moodle_net, :app_name))}
  end
end
