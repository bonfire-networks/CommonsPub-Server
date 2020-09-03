defmodule MoodleNetWeb.CommunityLive.CommunityCollectionsLive do
  use MoodleNetWeb, :live_component

  alias MoodleNetWeb.Helpers.{Profiles}

  alias MoodleNetWeb.GraphQL.{
    CollectionsResolver
  }

  alias MoodleNetWeb.Component.CollectionPreviewLive

  def update(assigns, socket) do
    {
      :ok,
      socket
      |> assign(assigns)
      |> fetch(assigns)
    }
  end

  def fetch(socket, assigns) do
    {:ok, collections} =
      CollectionsResolver.collections_edge(
        %{id: assigns.context.id},
        %{limit: 10},
        %{context: %{current_user: assigns.current_user}}
      )

    collections_list =
      Enum.map(
        collections.edges,
        &Profiles.prepare(&1, %{icon: false, image: false, actor: true})
      )

    assign(socket,
      collections: collections_list,
      has_next_page: collections.page_info.has_next_page,
      after: collections.page_info.end_cursor,
      before: collections.page_info.start_cursor
    )
  end

  def handle_event("load-more", _, socket),
    do: MoodleNetWeb.Helpers.Common.paginate_next(&fetch/2, socket)
end
