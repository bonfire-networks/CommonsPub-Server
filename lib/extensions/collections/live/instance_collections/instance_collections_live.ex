defmodule CommonsPub.Web.InstanceLive.InstanceCollectionsLive do
  use CommonsPub.Web, :live_component

  alias CommonsPub.Web.Helpers.{Profiles}

  alias CommonsPub.Web.GraphQL.{
    CollectionsResolver
  }

  alias CommonsPub.Web.Component.CollectionPreviewLive

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
      CollectionsResolver.collections(
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
    do: CommonsPub.Web.Helpers.Common.paginate_next(&fetch/2, socket)

  def render(assigns) do
    ~L"""
      <div
      id="instance-collections">
        <div
        phx-update="append"
        data-page="<%= @page %>"
        class="selected__area">
          <%= for collection <- @collections do %>
          <div class="preview__wrapper"
            id="collection-#{collection.id}-wrapper"
          >
            <%= live_component(
                  @socket,
                  CollectionPreviewLive,
                  id: "collection-#{collection.id}",
                  collection: collection
                )
              %>
            </div>
          <% end %>
        </div>
        <%= if @has_next_page do %>
        <div class="pagination">
          <button
            class="button--outline"
            phx-click="load-more"
            phx-target="<%= @pagination_target %>">
            load more
          </button>
        </div>
        <% end %>
      </div>
    """
  end
end
