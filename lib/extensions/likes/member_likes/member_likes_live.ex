defmodule CommonsPub.Web.MemberLive.MemberLikesLive do
  use CommonsPub.Web, :live_component

  # import CommonsPub.Web.Helpers.Common

  alias CommonsPub.Web.GraphQL.{
    LikesResolver
  }

  alias CommonsPub.Web.Component.{
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

  def fetch(socket, assigns) do
    {:ok, likes} =
      LikesResolver.likes_edge(
        %{id: assigns.user.id},
        %{after: assigns.after, limit: 10},
        %{context: %{current_user: assigns.current_user}}
      )

    # IO.inspect(likes, label: "LIKES:")

    assign(socket,
      activities: likes.edges,
      has_next_page: likes.page_info.has_next_page,
      after: likes.page_info.end_cursor,
      before: likes.page_info.start_cursor
    )
  end

  def handle_event("load-more", _, socket),
    do: CommonsPub.Web.Helpers.Common.paginate_next(&fetch/2, socket)

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
