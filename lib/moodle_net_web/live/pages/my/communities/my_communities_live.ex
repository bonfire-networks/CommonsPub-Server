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

  defp fetch(socket, assigns) do
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

    # IO.inspect(communities_follows: communities_follows)

    my_communities =
      if(communities_follows) do
        Communities.communities_from_follows(communities_follows)
      end

    # IO.inspect(communities: my_communities)

    assign(socket,
      my_communities: my_communities,
      has_next_page: communities_follows.page_info.has_next_page,
      after: communities_follows.page_info.end_cursor,
      before: communities_follows.page_info.start_cursor
    )
  end

  def handle_event("load-more", _, %{assigns: assigns} = socket) do
    {:noreply, socket |> assign(page: assigns.page + 1) |> fetch(assigns)}
  end
end
