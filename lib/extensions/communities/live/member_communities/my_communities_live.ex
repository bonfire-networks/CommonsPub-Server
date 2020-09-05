defmodule CommonsPub.Web.MemberLive.MemberCommunitiesLive do
  use CommonsPub.Web, :live_component

  alias CommonsPub.Communities.Web.CommunitiesHelper

  alias CommonsPub.Web.Component.CommunityPreviewLive

  def mount(socket) do
    {
      :ok,
      socket
      |> assign(
        page: 1,
        has_next_page: false,
        after: [],
        before: [],
        # activities: [],
        pagination_target: "#member_communities"
      )
      #  |> fetch(), temporary_assigns: [activities: []]
    }
  end

  def update(assigns, socket) do
    {
      :ok,
      socket
      |> assign(assigns)
      |> fetch(assigns)
    }
  end

  def fetch(socket, assigns) do
    # TODO: pagination
    communities =
      if(assigns.current_user == assigns.user and assigns.my_communities) do
        assigns.my_communities
      else
        CommunitiesHelper.user_communities(assigns.user, assigns.current_user)
      end

    # IO.inspect(communities: communities)

    assign(socket,
      member_communities: communities
      # has_next_page: communities.page_info.has_next_page,
      # after: communities.page_info.end_cursor,
      # before: communities.page_info.start_cursor
    )
  end

  def handle_event("load-more", _, socket),
    do: CommonsPub.Utils.Web.CommonHelper.paginate_next(&fetch/2, socket)

  def render(assigns) do
    ~L"""
      <div id="member-communities">
        <div
        phx-update="append"
        data-page="<%= @page %>"
        class="selected__area">
          <%= for community <- @member_communities do %>
          <div class="preview__wrapper">
            <%= live_component(
                  @socket,
                  CommunityPreviewLive,
                  id: "community-#{community.id}",
                  community: community,
                  current_user: @current_user
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
