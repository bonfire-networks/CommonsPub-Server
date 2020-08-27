defmodule MoodleNetWeb.InstanceLive.InstanceActivitiesLive do
  use MoodleNetWeb, :live_component

  alias MoodleNetWeb.Component.{
    ActivitiesListLive
  }

  alias MoodleNetWeb.GraphQL.{
    InstanceResolver
  }

  @doc """
  Handle pushed activities from PubSub
  """
  def update(%{activity: activity}, socket),
    do: MoodleNetWeb.Helpers.Activites.pubsub_receive(activity, socket)

  @doc """
  Load initial activities
  """
  def update(assigns, socket) do
    IO.inspect(update_assigns: assigns)

    {
      :ok,
      socket
      |> assign(assigns)
      |> fetch(assigns)
    }
  end

  @doc """
  Load a page of activities
  """
  def fetch(socket, assigns),
    do:
      MoodleNetWeb.Helpers.Activites.outbox_live(
        &MoodleNet.Feeds.instance_outbox_id/0,
        &MoodleNet.Instance.default_outbox_query_contexts/0,
        assigns,
        socket
      )

  def handle_event("load-more", _, socket),
    do: MoodleNetWeb.Helpers.Common.paginate_next(&fetch/2, socket)

  def render(assigns) do
    ~L"""
      <div id="instance_activities">

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
