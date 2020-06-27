defmodule MoodleNetWeb.InstanceLive.MembersTabLive do
  use MoodleNetWeb, :live_component

  alias MoodleNetWeb.Component.{
    UserPreviewLive
  }

  alias MoodleNetWeb.GraphQL.{
    UsersResolver
  }

  def mount(socket) do
    {:ok,
     socket
     |> assign(
       page: 1,
       has_next_page: false,
       after: [],
       before: []
     )
     |> fetch(), temporary_assigns: [members: []]}
  end

  defp fetch(socket) do
    {:ok, users} = UsersResolver.users(%{after: socket.assigns.after, limit: 10}, %{})

    assign(socket,
      members: users.edges,
      has_next_page: users.page_info.has_next_page,
      after: users.page_info.end_cursor,
      before: users.page_info.start_cursor
    )
  end

  def handle_event("load-more", _, %{assigns: assigns} = socket) do
    {:noreply, socket |> assign(page: assigns.page + 1) |> fetch()}
  end

  def render(assigns) do
    ~L"""
    <div class="selected__area">
    <div
    id="load-more-members"
    phx-update="append"
    data-page="<%= @page %>"
    class="users_list">
    <%= for user <- @members do %>
    <%= live_component(
        @socket,
        UserPreviewLive,
        id: "member-#{user.id}",
        user: user
      )
    %>
    <% end %>
    </div>
    </div>
    <%= if @has_next_page do %>
    <div class="pagination">
      <button
        class="button button-outline"
        phx-click="load-more"
        phx-target="<%= @myself %>">
        load more
      </button>
    </div>
    <% end %>
    """
  end
end
