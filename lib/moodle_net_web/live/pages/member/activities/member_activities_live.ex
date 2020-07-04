defmodule MoodleNetWeb.MemberLive.MemberActivitiesLive do
  use MoodleNetWeb, :live_component
  import MoodleNetWeb.Helpers.Common

  alias MoodleNetWeb.GraphQL.{
    UsersResolver
  }

  alias MoodleNetWeb.Component.{
    ActivitiesListLive
  }

  # def mount(socket) do
  #   # IO.inspect(assigns)

  #   {
  #     :ok,
  #     socket,
  #     temporary_assigns: [activities: [], page: 1, has_next_page: false, after: [], before: []]
  #   }
  # end

  def update(assigns, socket) do
    {
      :ok,
      socket
      |> assign(assigns)
      |> fetch(assigns)
    }
  end

  defp fetch(socket, assigns) do
    {:ok, outboxes} =
      UsersResolver.user_outbox_edge(
        assigns.user,
        %{after: assigns.after, limit: 10},
        # %{after: socket.assigns.after, before: socket.assigns.before, limit: 10},
        %{context: %{current_user: assigns.current_user}}
      )

    assign(socket,
      activities: outboxes.edges,
      has_next_page: outboxes.page_info.has_next_page,
      after: outboxes.page_info.end_cursor,
      before: outboxes.page_info.start_cursor
    )
  end

  def handle_event("load-more", _, %{assigns: assigns} = socket) do
    {:noreply, socket |> assign(page: assigns.page + 1) |> fetch(assigns)}
  end

  def render(assigns) do
    ~L"""
    <div id="member-activities">
    <%= live_component(
      @socket,
      ActivitiesListLive,
      assigns
      )
    %>
    </div>
    """
  end
end
