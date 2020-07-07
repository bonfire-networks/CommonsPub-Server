defmodule MoodleNetWeb.InstanceLive.InstanceCommunitiesLive do
  use MoodleNetWeb, :live_component

  alias MoodleNetWeb.GraphQL.{
    CommunitiesResolver
  }
  alias MoodleNetWeb.Component.CommunityPreviewLive

  def update(assigns, socket) do
    {
      :ok,
      socket
      |> assign(assigns)
      |> fetch(assigns)
    }
  end

  defp fetch(socket, assigns) do

    {:ok, communities} =
      CommunitiesResolver.communities(
        %{limit: 10},
        %{context: %{current_user: assigns.current_user}}
      )

    IO.inspect(communities: communities)

    assign(socket,
      communities: communities.edges,
      has_next_page: communities.page_info.has_next_page,
      after: communities.page_info.end_cursor,
      before: communities.page_info.start_cursor
    )
  end

  def handle_event("load-more", _, %{assigns: assigns} = socket) do
    {:noreply, socket |> assign(page: assigns.page + 1) |> fetch(assigns)}
  end

  def render(assigns) do
    ~L"""
      <div id="instance-communities">
        <div
        phx-update="append"
        data-page="<%= @page %>"
        class="selected__area">
          <%= for community <- @communities do %>
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
