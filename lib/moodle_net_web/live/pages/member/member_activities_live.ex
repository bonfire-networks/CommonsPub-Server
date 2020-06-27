defmodule MoodleNetWeb.MemberLive.MemberActivitiesLive do
  use MoodleNetWeb, :live_component

  import MoodleNetWeb.Helpers.Common

  alias MoodleNetWeb.Component.{
    ActivitiesLive
  }

  alias MoodleNetWeb.GraphQL.{
    UsersResolver
  }

  def mount(socket) do
    # IO.inspect(assigns)

    {
      :ok,
      socket,
      temporary_assigns: [activities: [], page: 1, has_next_page: false, after: [], before: []]
    }
  end

  def update(assigns, socket) do
    IO.inspect(assigns)

    {
      :ok,
      socket
      |> assign(
        # FIXME, user not found
        user: assigns.user
      )
      |> fetch()
    }
  end

  defp fetch(socket) do
    # TODO: replace with logged in user's inbox
    {:ok, outboxes} =
      UsersResolver.user_outbox_edge(
        socket.assigns.user,
        %{after: socket.assigns.after, limit: 10},
        # %{after: socket.assigns.after, before: socket.assigns.before, limit: 10},
        %{}
      )

    assign(socket,
      activities: outboxes.edges,
      has_next_page: outboxes.page_info.has_next_page,
      after: outboxes.page_info.end_cursor,
      before: outboxes.page_info.start_cursor
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
