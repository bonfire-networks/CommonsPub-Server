defmodule MoodleNetWeb.Page.Unknown do
  use MoodleNetWeb, :live_view

  import MoodleNetWeb.Helpers.Common

  def mount(params, session, socket) do
    socket = init_assigns(params, session, socket)

    {:ok,
     socket
     |> assign(current_user: socket.assigns.current_user)
     |> assign(object: %{})
     |> assign(object_type: nil)}
  end

  def handle_params(%{} = params, url, socket) do
    obj = context_fetch(params["id"])

    {:noreply,
     socket
     |> assign(current_user: socket.assigns.current_user)
     |> assign(object: obj)
     |> assign(object_type: context_type(obj))}
  end
end
