defmodule MoodleNetWeb.My.SidebarCommunitiesLive do
  use MoodleNetWeb, :live_component

  import MoodleNetWeb.Helpers.Common

  alias MoodleNetWeb.Helpers.{Profiles, Communities}

  alias MoodleNetWeb.GraphQL.{
    CommonResolver,
    UsersResolver
  }

  def update(assigns, socket) do
    {
      :ok,
      socket
      # |> assign(assigns)
      |> fetch(assigns)
    }
  end

  defp fetch(socket, assigns) do
    # IO.inspect(my_user: assigns.current_user)

    if(assigns.current_user) do
      {:ok, communities} =
        UsersResolver.community_follows_edge(
          assigns.current_user,
          %{limit: 10},
          %{context: %{current_user: assigns.current_user}}
        )

      # IO.inspect(my_follows: communities)

      # FIXME: communities should be joined rather than queried one by one
      my_communities =
        Enum.map(
          communities.edges,
          &CommonResolver.context_edge(&1, nil, nil)
        )

      my_communities =
        Enum.map(
          my_communities,
          &Communities.prepare(&1, %{icon: true, image: true, actor: true})
        )

      # IO.inspect(my_communities: my_communities)

      assign(socket,
        communities: my_communities,
        has_next_page: communities.page_info.has_next_page,
        after: communities.page_info.end_cursor,
        before: communities.page_info.start_cursor
      )
    else
      nil
    end
  end

  def handle_event("load-more", _, %{assigns: assigns} = socket) do
    {:noreply, socket |> assign(page: assigns.page + 1) |> fetch(assigns)}
  end
end
