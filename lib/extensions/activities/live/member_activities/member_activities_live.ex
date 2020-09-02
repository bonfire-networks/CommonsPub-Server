defmodule MoodleNetWeb.MemberLive.MemberActivitiesLive do
  use MoodleNetWeb, :live_component

  # import MoodleNetWeb.Helpers.Common

  alias MoodleNetWeb.GraphQL.{
    UsersResolver
  }

  alias MoodleNetWeb.Component.{
    ActivitiesListLive
  }

  @doc """
  Handle pushed activities from PubSub
  """
  def update(%{activity: activity}, socket),
    do: MoodleNetWeb.Helpers.Activites.pubsub_receive(activity, socket)

  def update(assigns, socket) do
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
        {&MoodleNet.Feeds.outbox_id/1, assigns.user},
        &MoodleNet.Users.default_outbox_query_contexts/0,
        assigns,
        socket
      )

  def handle_event("load-more", _, socket),
    do: MoodleNetWeb.Helpers.Common.paginate_next(&fetch/2, socket)

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
