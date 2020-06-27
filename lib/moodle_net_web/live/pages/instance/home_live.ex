defmodule MoodleNetWeb.InstanceLive do
  use MoodleNetWeb, :live_view

  alias MoodleNetWeb.Component.{
    HeaderLive,
    AboutLive,
    TabNotFoundLive
  }

  alias MoodleNetWeb.InstanceLive.{
    InstanceActivitiesLive,
    MembersTabLive
  }

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(
       page_title: "Home",
       hostname: MoodleNet.Instance.hostname(),
       description: MoodleNet.Instance.description(),
       selected_tab: "about"
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
        <h1><%= @hostname %></h1>
      </div>

      <div class="mainContent__navigation home__navigation">
          <%= live_patch link_body("About", "feather-book-open"),
            # to: Routes.live_path(
            #   @socket,
            #   __MODULE__,
            #   tab: "about"
            #   ),
            to: "/instance/about",
            class: if @selected_tab == "about", do: "navigation__item active", else: "navigation__item"
          %>
          <%= live_patch link_body("Timeline","feather-activity"),
            # to: Routes.live_path(
            #   @socket,
            #   __MODULE__,
            #   tab: "timeline"
            #   ),
            to: "/instance/timeline",
            class: if @selected_tab == "timeline", do: "navigation__item active", else: "navigation__item"
          %>
          <%= live_patch link_body("Members", "feather-users"),
            # to: Routes.live_path(
            #   @socket,
            #   __MODULE__,
            #   tab: "members"
            #   ),
            to: "/instance/members",
            class: if @selected_tab == "members", do: "navigation__item active", else: "navigation__item"
          %>
      </div>
      <div class="mainContent__selected">

          <%= cond do %>
          <% @selected_tab == "about" ->  %>
            <div class="selected__header">
              <h3><%= @selected_tab %></h3>
            </div>
            <div class="selected__area">
              <%= live_component(
                  @socket,
                  AboutLive,
                  description: @description
                )
              %>
            </div>
          <% @selected_tab == "timeline" -> %>
            <%= live_component(
                @socket,
                InstanceActivitiesLive,
                selected_tab: @selected_tab,
                id: :timeline
              ) %>
         <% @selected_tab == "members" -> %>
          <%= live_component(
              @socket,
              MembersTabLive,
              selected_tab: @selected_tab,
              id: :members
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
