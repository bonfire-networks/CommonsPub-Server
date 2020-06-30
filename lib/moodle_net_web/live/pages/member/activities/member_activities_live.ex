defmodule MoodleNetWeb.MemberLive.MemberActivitiesLive do
  use MoodleNetWeb, :live_component
  import MoodleNetWeb.Helpers.Common

  alias MoodleNetWeb.GraphQL.{
    UsersResolver
  }

  alias MoodleNetWeb.Component.{
    ActivitiesListLive
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
    {
      :ok,
      socket
      |> assign(
        current_user: assigns.current_user,
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
        %{context: %{current_user: socket.assigns.current_user}}
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
      ActivitiesListLive,
      assigns
      )
    %>
    """
  end
end
