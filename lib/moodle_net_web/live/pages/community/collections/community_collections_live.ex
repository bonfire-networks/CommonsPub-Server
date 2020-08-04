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

  defp fetch(socket, assigns) do
    {:ok, collections} =
      CollectionsResolver.collections(
        %{limit: 10},
        %{context: %{current_user: assigns.current_user}}
      )

    # IO.inspect(collections: collections)

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

  def handle_event("load-more", _, %{assigns: assigns} = socket) do
    {:noreply, socket |> assign(page: assigns.page + 1) |> fetch(assigns)}
  end
end
