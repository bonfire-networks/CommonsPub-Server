defmodule MoodleNetWeb.My.TimelineLive do
  use MoodleNetWeb, :live_component

  alias MoodleNetWeb.Component.{
    ActivitiesListLive
  }

  alias MoodleNetWeb.GraphQL.{
    UsersResolver
  }

  # def mount(socket) do
  #   {
  #     :ok,
  #     socket
  #     |> assign(
  #       page: 1,
  #       has_next_page: false,
  #       after: [],
  #       before: [],
  #       activities: [],
  #       pagination_target: "my_timeline"
  #     )
  #     #  |> fetch(), temporary_assigns: [activities: []]
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
    # IO.inspect(inbox_for: assigns.current_user)

    {:ok, inbox} =
      UsersResolver.user_inbox_edge(
        assigns.current_user,
        %{after: assigns.after, limit: 10},
        %{context: %{current_user: assigns.current_user}}
      )

    # IO.inspect(inbox: inbox)

    assign(socket,
      activities: inbox.edges,
      has_next_page: inbox.page_info.has_next_page,
      after: inbox.page_info.end_cursor,
      before: inbox.page_info.start_cursor
    )
  end

  def handle_event("load-more", _, %{assigns: assigns} = socket) do
    {:noreply, socket |> assign(page: assigns.page + 1) |> fetch(assigns)}
  end

  def render(assigns) do
    ~L"""
    <div id="my-timeline">
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