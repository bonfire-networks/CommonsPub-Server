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
  #       current_user: socket.assigns.current_user
  #     )
  #     #  |> fetch(), temporary_assigns: [activities: []]
  #   }
  # end

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
      MoodleNetWeb.Helpers.Activites.inbox_live(
        assigns.current_user,
        assigns,
        socket
      )

  def handle_event("load-more", _, socket),
    do: MoodleNetWeb.Helpers.Common.paginate_next(&fetch/2, socket)

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
