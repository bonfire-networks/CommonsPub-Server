defmodule CommonsPub.Web.CommunityLive.CommunityActivitiesLive do
  use CommonsPub.Web, :live_component

  alias CommonsPub.Web.Component.{
    ActivitiesListLive
  }

  alias CommonsPub.Web.GraphQL.{
    CommunitiesResolver
  }

  # def mount(socket) do
  #   {
  #     :ok,
  #     socket,
  #     temporary_assigns: [
  #       activities: [],
  #       page: 1,
  #       has_next_page: false,
  #       after: [],
  #       before: [],
  #       pagination_target: "#instance-activities"
  #     ]
  #   }
  # end

  @doc """
  Handle pushed activities from PubSub
  """
  def update(%{activity: activity}, socket),
    do: CommonsPub.Web.Helpers.Activites.pubsub_receive(activity, socket)

  def update(assigns, socket) do
    # IO.inspect(assigns, label: "ASSIGNS:")
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
      CommonsPub.Web.Helpers.Activites.outbox_live(
        {&CommonsPub.Feeds.outbox_id/1, assigns.community},
        &CommonsPub.Communities.default_outbox_query_contexts/0,
        assigns,
        socket
      )

  def handle_event("load-more", _, socket),
    do: CommonsPub.Web.Helpers.Common.paginate_next(&fetch/2, socket)

  def render(assigns) do
    ~L"""
      <div id="community-activities">
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
