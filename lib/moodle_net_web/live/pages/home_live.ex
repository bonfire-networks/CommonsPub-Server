defmodule MoodleNetWeb.HomeLive do
  use MoodleNetWeb, :live_view
  alias MoodleNetWeb.Component.{
    HeaderLive,
    ActivityLive,
    AboutLive,
    StoryPreviewLive,
    UserPreviewLive,
    DiscussionPreviewLive
  }
  alias MoodleNetWeb.GraphQL.{
    UsersResolver,
    InstanceResolver
  }

  def mount(_params, _session, socket) do
    {:ok, users} = UsersResolver.users(%{limit: 10}, %{})
    {:ok, outboxes} = InstanceResolver.outbox_edge(%{}, %{limit: 10}, %{})
    {:ok, assign(socket,
      page_title: "Home",
      hostname: MoodleNet.Instance.hostname,
      description: MoodleNet.Instance.description,
      outbox: outboxes.edges,
      users: users.edges,
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
        HeaderLive,
        icon: "https://home.next.moodle.net/uploads/01E9TQEVAKAVNZCQVE94NJA7TP/moebius4.jpeg"
      )
    %>
    <section class="page__wrapper">
      <div class="instance_hero">
        <h1><%= @hostname %></h1>
      </div>
      <div class="mainContent__navigation home__navigation">
          <%= live_patch link_body("About", "feather-book-open"),
            to: Routes.live_path(
              @socket,
              __MODULE__,
              tab: "about"
              ),
            class: if @selected_tab == "about", do: "navigation__item active", else: "navigation__item"
          %>
          <%= live_patch link_body("Timeline","feather-activity"),
            to: Routes.live_path(
              @socket,
              __MODULE__,
              tab: "timeline"
              ),
            class: if @selected_tab == "timeline", do: "navigation__item active", else: "navigation__item"
          %>
          <%= live_patch link_body("Members", "feather-users"),
            to: Routes.live_path(
              @socket,
              __MODULE__,
              tab: "members"
              ),
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
            <div class="selected__header">
              <h3><%= @selected_tab %></h3>
            </div>
            <div class="selected__area">
                <%= for activity <- @outbox do %>
                <%= live_component(
                      @socket,
                      ActivityLive,
                      activity: activity
                    )
                  %>
              <% end %>
            </div>
         <% @selected_tab == "members" -> %>
          <div class="selected__header">
              <h3><%= @selected_tab %></h3>
            </div>
            <div class="selected__area">
            <div class="users_list">
              <%= for user <- @users do %>
                <%= live_component(
                  @socket,
                  UserPreviewLive,
                  user: user
                  )
                %>
              <% end %>
            </div>
            </div>
          <% true -> %>
          <div class="selected__header">
            <h3>Section not found</h3>
          </div>
          <div class="selected__area">

            </div>
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
