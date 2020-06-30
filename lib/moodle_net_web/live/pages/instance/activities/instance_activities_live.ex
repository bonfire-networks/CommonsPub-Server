defmodule MoodleNetWeb.InstanceLive.InstanceActivitiesLive do
  use MoodleNetWeb, :live_component

  alias MoodleNetWeb.Component.{
    ActivitiesListLive
  }

  alias MoodleNetWeb.GraphQL.{
    InstanceResolver
  }

  def mount(socket) do
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
      |> assign(current_user: assigns.current_user)
      |> fetch()
    }
  end

  defp fetch(socket) do
    {:ok, outboxes} =
      InstanceResolver.outbox_edge(
        %{},
        %{after: socket.assigns.after, before: socket.assigns.before, limit: 10},
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
      <div id="<%= @page %>-activities">
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
