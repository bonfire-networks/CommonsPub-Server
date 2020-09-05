defmodule CommonsPub.Web.MemberLive.MemberActivitiesLive do
  use CommonsPub.Web, :live_component

  # import CommonsPub.Utils.Web.CommonHelper

  alias CommonsPub.Web.Component.{
    ActivitiesListLive
  }

  @doc """
  Handle pushed activities from PubSub
  """
  def update(%{activity: activity}, socket),
    do: CommonsPub.Activities.Web.ActivitiesHelper.pubsub_receive(activity, socket)

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
      CommonsPub.Activities.Web.ActivitiesHelper.outbox_live(
        {&CommonsPub.Feeds.outbox_id/1, assigns.user},
        &CommonsPub.Users.default_outbox_query_contexts/0,
        assigns,
        socket
      )

  def handle_event("load-more", _, socket),
    do: CommonsPub.Utils.Web.CommonHelper.paginate_next(&fetch/2, socket)

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
