defmodule MoodleNetWeb.My.MyCommunitiesLive do
  use MoodleNetWeb, :live_component

  alias MoodleNetWeb.Helpers.{Communities}

  alias MoodleNetWeb.Component.CommunityPreviewLive

  def mount(socket) do
    {
      :ok,
      socket
      |> assign(
        page: 1,
        pagination_target: "#my_communities"
      )
    }
  end

  # def update(assigns, socket) do
  #   {
  #     :ok,
  #     socket
  #     |> assign(assigns)
  #     # |> fetch(assigns)
  #   }
  # end

  def fetch(socket, assigns) do
    # TODO: pagination

    communities_follows =
      if(assigns.current_user) do
        Communities.user_communities_follows(
          assigns.current_user,
          assigns.current_user,
          10,
          assigns.after
        )
      end

    my_communities =
      if(communities_follows) do
        Communities.communities_from_follows(communities_follows)
      end

    assign(socket,
      my_communities: my_communities,
      has_next_page: communities_follows.page_info.has_next_page,
      after: communities_follows.page_info.end_cursor,
      before: communities_follows.page_info.start_cursor
    )
  end

  def handle_event("load-more", _, socket),
    do: MoodleNetWeb.Helpers.Common.paginate_next(&fetch/2, socket)
end
