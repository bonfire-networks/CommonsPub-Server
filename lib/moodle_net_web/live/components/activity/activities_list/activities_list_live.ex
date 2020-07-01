defmodule MoodleNetWeb.Component.ActivitiesListLive do
  use MoodleNetWeb, :live_component
  alias MoodleNetWeb.Component.{ActivityLive}

  def render(assigns) do
    ~L"""
    <div
    phx-update="append"
    data-page="<%= @page %>"
    class="selected__area">
      <%= for activity <- @activities do %>
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
        class="button--outline"
        phx-click="load-more"
        phx-target="<%= @myself %>">
        load more
      </button>
    </div>
    <% end %>
    """
  end
end
