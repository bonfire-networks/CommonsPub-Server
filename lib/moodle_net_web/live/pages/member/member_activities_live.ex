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
    IO.inspect(socket)

    {
      :ok,
      socket
      |> assign(
        page: 1,
        has_next_page: false,
        after: [],
        before: [],
        activities: [],
        # FIXME, user not found
        user: socket.assigns.user
      )
      |> fetch(),
      temporary_assigns: [activities: []]
    }
  end

  defp fetch(socket) do
    # TODO: replace with logged in user's inbox
    {:ok, outboxes} =
      UsersResolver.outbox_edge(
        %{outbox_id: socket.assigns.user.outbox_id},
        %{after: socket.assigns.after, before: socket.assigns.before, limit: 10},
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
