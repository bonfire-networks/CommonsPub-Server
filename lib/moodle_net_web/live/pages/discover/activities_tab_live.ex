defmodule MoodleNetWeb.Discover.ActivitiesTabLive do
  use MoodleNetWeb, :live_component
  alias MoodleNetWeb.Component.{
    ActivityLive
  }
  alias MoodleNetWeb.GraphQL.{
    InstanceResolver
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
      |> fetch(), temporary_assigns: [outbox: []]}
  end

  defp fetch(socket) do
    {:ok, outboxes} = InstanceResolver.outbox_edge(%{}, %{after: socket.assigns.after, before: socket.assigns.before, limit: 10}, %{})
    assign(socket,
      outbox: outboxes.edges,
      has_next_page: outboxes.page_info.has_next_page,
      after: outboxes.page_info.end_cursor,
      before: outboxes.page_info.start_cursor
    )
  end

  def handle_event("load-more", _, %{assigns: assigns} = socket) do
    {:noreply, socket |> assign(page: assigns.page + 1) |> fetch()}
  end

  def render(assigns) do
 ~L"""
  <div class="selected__header">
    <h3><%= @selected_tab %></h3>
  </div>
  <div
    id="infinte-scroll-activities"
    phx-update="append"
    data-page="<%= @page %>"
    class="selected__area">
      <%= for activity <- @outbox do %>
        <%= live_component(
              @socket,
              ActivityLive,
              id: "activity-#{activity.id}",
              activity: activity
            )
          %>
      <% end %>
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
