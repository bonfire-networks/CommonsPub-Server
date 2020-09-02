defmodule CommonsPub.Web.Component.ResourcesListLive do
  use CommonsPub.Web, :live_component
  alias CommonsPub.Web.Component.{ResourcePreviewLive}

  def render(assigns) do
    ~L"""
    <div
    phx-update="append"
    data-page="<%= @page %>"
    class="selected__area">
      <%= for resource <- @resources do %>
        <%= live_component(
              @socket,
              ResourcePreviewLive,
              id: "resource-preview-#{resource.id}",
              resource: resource,
              current_user: @current_user,
              reply_link: nil
            )
          %>
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
    """
  end
end
