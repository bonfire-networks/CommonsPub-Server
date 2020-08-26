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
      # |> fetch(socket.assigns)
    }
  end

  @doc """
  Handle pushed activities from PubSub
  """
  def update(%{activity: activity}, socket) do
    IO.inspect(pushed_activity: activity)

    {
      :ok,
      socket
      |> assign(:activities, List.insert_at(socket.assigns.activities, 0, activity))
    }
  end

  @doc """
  Load initial activities
  """
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

    feed_id = MoodleNet.Feeds.instance_outbox_id()
    tables = MoodleNet.Instance.default_outbox_query_contexts()

    {:ok, outboxes} =
      MoodleNetWeb.GraphQL.ActivitiesResolver.fetch_outbox_edge(
        feed_id,
        tables,
        %{after: assigns.after, limit: 10}
      )

    # subscribe to the feed for realtime updates
    if connected?(socket), do: MoodleNet.Feeds.FeedActivities.pubsub_subscribe(feed_id)

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
