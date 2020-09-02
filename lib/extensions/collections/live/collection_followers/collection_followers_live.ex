defmodule CommonsPub.Web.CollectionLive.CollectionFollowersLive do
  use CommonsPub.Web, :live_component

  alias CommonsPub.Web.Component.{
    UserPreviewLive
  }

  def update(assigns, socket) do
    {
      :ok,
      socket
      |> assign(assigns)
      |> fetch(assigns)
    }
  end

  def fetch(socket, assigns) do
    {:ok, users} =
      CommonsPub.Web.GraphQL.UsersResolver.user_follows_edge(
        %{id: assigns.collection.id},
        %{limit: 10},
        %{context: %{current_user: assigns.current_user}}
      )

    assign(socket,
      followers: users.edges,
      has_next_page: users.page_info.has_next_page,
      after: users.page_info.end_cursor,
      before: users.page_info.start_cursor
    )
  end

  def handle_event("load-more", _, socket),
    do: CommonsPub.Web.Helpers.Common.paginate_next(&fetch/2, socket)
end
