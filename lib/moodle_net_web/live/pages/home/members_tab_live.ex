defmodule MoodleNetWeb.Home.MembersTabLive do
  use MoodleNetWeb, :live_component

  alias MoodleNetWeb.Component.{
    UserPreviewLive
  }

  alias MoodleNetWeb.GraphQL.{
    UsersResolver
  }

  def mount(socket) do
    {:ok,
     socket
     |> assign(
       page: 1,
       has_next_page: false,
       after: [],
       before: []
     )
     |> fetch(), temporary_assigns: [members: []]}
  end

  defp fetch(socket) do
    {:ok, users} = UsersResolver.users(%{after: socket.assigns.after, limit: 10}, %{})

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

  def render(assigns) do
    ~L"""
    <%= live_component(
        @socket,
        ActivitiesLive,
        page: @page,
        myself: @myself,
        has_next_page: @has_next_page,
        activities: @activities
      )
    %>
    """
  end
end
