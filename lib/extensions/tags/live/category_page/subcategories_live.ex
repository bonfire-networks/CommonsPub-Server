defmodule CommonsPub.Web.Page.Category.SubcategoriesLive do
  use CommonsPub.Web, :live_component

  import CommonsPub.Utils.Web.CommonHelper

  # alias CommonsPub.Profiles.Web.ProfilesHelper

  alias CommonsPub.Web.Component.CategoryPreviewLive

  def update(assigns, socket) do
    {
      :ok,
      socket
      |> assign(assigns)
      |> fetch(assigns)
    }
  end

  def fetch(socket, assigns) do
    IO.inspect(assigns)

    {:ok, categories} =
      CommonsPub.Tag.GraphQL.TagResolver.category_children(
        %{id: assigns.category_id},
        %{limit: 15},
        %{context: %{current_user: assigns.current_user}}
      )

    # IO.inspect(categories: categories)

    categories_list =
      Enum.map(
        categories.edges,
        &prepare_common(&1)
      )

    assign(socket,
      categories: categories_list,
      has_next_page: categories.page_info.has_next_page,
      after: categories.page_info.end_cursor,
      before: categories.page_info.start_cursor
    )
  end

  def handle_event("load-more", _, socket),
    do: CommonsPub.Utils.Web.CommonHelper.paginate_next(&fetch/2, socket)

  def render(assigns) do
    ~L"""
      <div
      id="subcategories">
        <div
        phx-update="append"
        data-page="<%= @page %>"
        class="selected__area">
          <%= for category <- @categories do %>
          <div class="preview__wrapper"
            id="category-#{category.id}-wrapper"
          >
            <%= live_component(
                  @socket,
                  CategoryPreviewLive,
                  id: "category-#{category.id}",
                  object: category
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
