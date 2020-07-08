defmodule MoodleNetWeb.CommunityLive.CommunityMembersLive do
  use MoodleNetWeb, :live_component

  alias MoodleNetWeb.GraphQL.{
    UsersResolver
  }
  alias MoodleNetWeb.Component.{
    UserPreviewLive
  }



  def update(assigns, socket) do
    # IO.inspect(assigns, label: "ASSIGNS:")
    {
      :ok,
      socket
      |> assign(assigns)
      |> fetch(assigns)
    }
  end

  defp fetch(socket, assigns) do
    # IO.inspect(after: assigns.after)

    {:ok, users} = MoodleNetWeb.GraphQL.UsersResolver.user_follows_edge(
        %{id: assigns.community.id},
        %{limit: 10},
        %{context: %{current_user: assigns.current_user}}
      )


     IO.inspect(users, label: "User COMMUNITY:")

    assign(socket,
      members: users.edges,
      has_next_page: users.page_info.has_next_page,
      after: users.page_info.end_cursor,
      before: users.page_info.start_cursor
    )
  end

  def handle_event("load-more", _, %{assigns: assigns} = socket) do
    {:noreply, socket |> assign(page: assigns.page + 1) |> fetch(assigns)}
  end


end
