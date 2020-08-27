defmodule MoodleNetWeb.Component.ActivitiesListLive do
  use MoodleNetWeb, :live_component
  alias MoodleNetWeb.Component.{ActivityLive}

  # def update(assigns, socket) do
  #   {
  #     :ok,
  #     socket
  #     # FIXME, workaround of assigns not present or complaint about flash
  #     |> assign(Map.drop(assigns, [:flash]))
  #   }
  # end

  def render(assigns) do
    # phx-update="append"
    ~L"""
    <div
    data-page="<%= @page %>"
    class="selected__area">
      <%= for activity <- @activities do %>
        <%= live_component(
              @socket,
              ActivityLive,
              id: "timeline-activity-#{activity.id}",
              activity: activity,
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
