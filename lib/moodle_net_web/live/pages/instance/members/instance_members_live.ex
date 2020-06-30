defmodule MoodleNetWeb.InstanceLive.InstanceMembersLive do
  use MoodleNetWeb, :live_component

  alias MoodleNetWeb.Component.{
    UserPreviewLive
  }

  alias MoodleNetWeb.GraphQL.{
    UsersResolver
  }

  def mount(socket) do
    {
      :ok,
      socket,
      temporary_assigns: [members: [], page: 1, has_next_page: false, after: [], before: []]
    }
  end

  def update(assigns, socket) do
    {
      :ok,
      socket
      |> assign(current_user: assigns.current_user)
      |> fetch()
    }
  end

  defp fetch(socket) do
    {:ok, users} =
      UsersResolver.users(%{after: socket.assigns.after, limit: 10}, %{
        context: %{current_user: socket.assigns.current_user}
      })

    assign(socket,
      members: users.edges,
      has_next_page: users.page_info.has_next_page,
      after: users.page_info.end_cursor,
      before: users.page_info.start_cursor
    )
  end

  def handle_event("load-more", _, %{assigns: assigns} = socket) do
    {:noreply, socket |> assign(page: assigns.page + 1) |> fetch()}
  end
end
