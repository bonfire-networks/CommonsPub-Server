defmodule MoodleNetWeb.MemberLive.SidebarGroupsLive do
  use MoodleNetWeb, :live_component

  import MoodleNetWeb.Helpers.Common

  alias MoodleNetWeb.Helpers.{Profiles}

  alias MoodleNetWeb.GraphQL.UsersResolver

  def update(assigns, socket) do
    {
      :ok,
      socket
      |> assign(assigns)
      |> fetch(assigns)
    }
  end

  defp fetch(socket, assigns) do
    # IO.inspect(assigns.user)
    {:ok, groups} =
      user =
      UsersResolver.community_follows_edge(
        %{id: assigns.user.id},
        %{limit: 10},
        %{context: %{current_user: assigns.current_user}}
      )

    IO.inspect(groups)

    assign(socket,
      groups: groups.edges,
      has_next_page: groups.page_info.has_next_page,
      after: groups.page_info.end_cursor,
      before: groups.page_info.start_cursor
    )
  end

  def handle_event("load-more", _, %{assigns: assigns} = socket) do
    {:noreply, socket |> assign(page: assigns.page + 1) |> fetch(assigns)}
  end
end
