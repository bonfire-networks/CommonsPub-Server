defmodule MoodleNetWeb.InstanceLive.InstanceActivitiesLive do
  use MoodleNetWeb, :live_component

  alias MoodleNetWeb.Component.{
    ActivitiesListLive
  }

  alias MoodleNetWeb.GraphQL.{
    InstanceResolver
  }

  def mount(_params, _session, socket) do
    # IO.inspect(socket, label: "SOCKET")
    {
      :ok,
      socket
      |> assign(current_user: socket.assigns.current_user)
      #  |> fetch(), temporary_assigns: [activities: []]
    }
  end

  def update(assigns, socket) do
    {
      :ok,
      socket
      |> assign(assigns)
      |> fetch(assigns)
    }
  end

  defp fetch(socket, assigns) do
    # IO.inspect(after: assigns.after)

    {:ok, outboxes} =
      InstanceResolver.outbox_edge(
        %{},
        %{after: assigns.after, limit: 10},
        %{context: %{current_user: assigns.current_user}}
      )

    # IO.inspect(outboxes: outboxes)

    assign(socket,
      activities: outboxes.edges,
      has_next_page: outboxes.page_info.has_next_page,
      after: outboxes.page_info.end_cursor,
      before: outboxes.page_info.start_cursor,
      current_user: assigns.current_user
    )
  end

  def handle_event("load-more", _, %{assigns: assigns} = socket) do
    {:noreply, socket |> assign(page: assigns.page + 1) |> fetch(assigns)}
  end

  def render(assigns) do
    ~L"""
      <div id="instance-activities">

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
