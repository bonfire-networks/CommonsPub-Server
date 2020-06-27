defmodule MoodleNetWeb.MyLive do
  use MoodleNetWeb, :live_view
  alias MoodleNetWeb.MyLive.ActivitiesTabLive

  alias MoodleNetWeb.Component.{
    HeaderLive,
    TabNotFoundLive
  }

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(
       page_title: "My Timeline",
       selected_tab: "timeline"
     )}
  end

  def handle_params(%{"tab" => tab}, _url, socket) do
    {:noreply, assign(socket, selected_tab: tab)}
  end

  def handle_params(_, _url, socket) do
    {:noreply, socket}
  end

  def render(assigns) do
    ~L"""
    <div class="page">
    <%= live_component(
        @socket,
        HeaderLive
      )
    %>
    <section class="page__wrapper">
      <div class="instance__hero">
        <h1>My Timeline</h1>
      </div>
      <div class="mainContent__navigation home__navigation">
      <%= live_patch link_body("Timeline","feather-activity"),
        # to: Routes.live_path(
        #   @socket,
        #   __MODULE__,
        #   tab: "timeline"
        #   ),
        to: "/my/timeline",
        class: if @selected_tab == "timeline", do: "navigation__item active", else: "navigation__item"
      %>
      <%= live_patch link_body("My Groups", "feather-users"),
            # to: Routes.live_path(
            #   @socket,
            #   __MODULE__,
            #   tab: "members"
            #   ),
            to: "/my/groups",
            class: if @selected_tab == "groups", do: "navigation__item active", else: "navigation__item"
          %>
      </div>
      <div class="mainContent__selected">
        <%= cond do %>
          <% @selected_tab == "timeline" -> %>
            <%= live_component(
                @socket,
                ActivitiesTabLive,
                selected_tab: @selected_tab,
                id: :timeline
              ) %>
          <% true -> %>
          <%= live_component(
              @socket,
              TabNotFoundLive
          ) %>
        <% end %>
      </div>
      </div>
    </section>
    </div>
    """
  end

  defp link_body(name, icon) do
    assigns = %{name: name, icon: icon}

    ~L"""
      <i class="<%= @icon %>"></i>
      <%= @name %>
    """
  end
end
