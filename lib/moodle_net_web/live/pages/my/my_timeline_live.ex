defmodule MoodleNetWeb.MyLive.MyTimelineLive do
  use MoodleNetWeb, :live_component

  alias MoodleNetWeb.Component.{
    ActivitiesLive
  }

  alias MoodleNetWeb.GraphQL.{
    InstanceResolver
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
     |> fetch(), temporary_assigns: [activities: []]}
  end

  defp fetch(socket) do
    # TODO: replace with logged in user's inbox
    {:ok, outboxes} =
      InstanceResolver.outbox_edge(
        %{},
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
