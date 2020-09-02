defmodule CommonsPub.Web.InstanceLive.InstanceCommunitiesLive do
  use CommonsPub.Web, :live_component

  alias CommonsPub.Profiles.Web.ProfilesHelper

  alias CommonsPub.Web.GraphQL.{
    CommunitiesResolver
  }

  alias CommonsPub.Web.Component.CommunityPreviewLive

  def update(assigns, socket) do
    {
      :ok,
      socket
      |> assign(assigns)
      |> fetch(assigns)
    }
  end

  def fetch(socket, assigns) do
    {:ok, communities} =
      CommunitiesResolver.communities(
        %{limit: 10},
        %{context: %{current_user: assigns.current_user}}
      )

    # IO.inspect(communities: communities)

    communities_list =
      Enum.map(
        communities.edges,
        &ProfilesHelper.prepare(&1, %{icon: true, image: true, character: true})
      )

    assign(socket,
      communities: communities_list,
      has_next_page: communities.page_info.has_next_page,
      after: communities.page_info.end_cursor,
      before: communities.page_info.start_cursor
    )
  end

  def handle_event("load-more", _, socket),
    do: CommonsPub.Utils.Web.CommonHelper.paginate_next(&fetch/2, socket)

  def render(assigns) do
    ~L"""
      <div
      id="instance-communities">
        <div
        phx-update="append"
        data-page="<%= @page %>"
        class="selected__area">
          <%= for community <- @communities do %>
          <div class="preview__wrapper"
            id="community-#{community.id}-wrapper"
          >
            <%= live_component(
                  @socket,
                  CommunityPreviewLive,
                  id: "community-#{community.id}",
                  community: community
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
