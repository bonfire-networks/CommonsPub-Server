defmodule MoodleNetWeb.SearchLive do
  use MoodleNetWeb, :live_view

  import MoodleNetWeb.Helpers.Common

  def mount(params, session, socket) do
    socket = init_assigns(params, session, socket)

    {:ok,
     socket
     |> assign(
       page_title: "Search",
       me: false
       #  current_user: socket.assigns.current_user
     )}
  end
end
