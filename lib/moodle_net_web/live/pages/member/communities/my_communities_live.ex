defmodule MoodleNetWeb.MemberLive.MemberCommunitiesLive do
  use MoodleNetWeb, :live_component

  alias MoodleNetWeb.Helpers.{Communities}

  alias MoodleNetWeb.Component.CommunityPreviewLive

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

  defp fetch(socket, assigns) do
    # TODO: pagination
    communities =
      if(assigns.current_user == assigns.user and assigns.my_communities) do
        assigns.my_communities
      else
        Communities.user_communities(assigns.user, assigns.current_user)
      end

    # IO.inspect(communities: communities)

    assign(socket,
      member_communities: communities
      # has_next_page: communities.page_info.has_next_page,
      # after: communities.page_info.end_cursor,
      # before: communities.page_info.start_cursor
    )
  end

  def handle_event("load-more", _, %{assigns: assigns} = socket) do
    {:noreply, socket |> assign(page: assigns.page + 1) |> fetch(assigns)}
  end

  def render(assigns) do
    ~L"""
      <div id="member_communities">
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
