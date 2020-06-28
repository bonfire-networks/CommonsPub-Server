defmodule MoodleNetWeb.My.Live do
  use MoodleNetWeb, :live_view

  import MoodleNetWeb.Helpers.Common

  alias MoodleNetWeb.My.TimelineLive

  alias MoodleNetWeb.Component.{
    HeaderLive,
    TabNotFoundLive
  }

  def mount(_params, session, socket) do
    {:ok, session_token} = MoodleNet.Access.fetch_token_and_user(session["auth_token"])
    user = e(session_token, :user, %{})

    app_name = Application.get_env(:moodle_net, :app_name)

    {:ok,
     socket
     |> assign(
       page_title: "My " <> app_name,
       selected_tab: "timeline",
       app_name: Application.get_env(:moodle_net, :app_name),
       current_user: user
     )}
  end

  def handle_params(%{"tab" => tab}, _url, socket) do
    {:noreply, assign(socket, selected_tab: tab)}
  end

  def handle_params(_, _url, socket) do
    {:noreply, socket}
  end

  def render(assigns) do
    IO.inspect(assigns.current_user)

    ~L"""
    <div class="page">
    <%= live_component(
        @socket,
        HeaderLive
      )
    %>
    <section class="page__wrapper">
      <div class="instance__hero">
        <h1><%=@page_title%></h1>
      </div>
      <div class="mainContent__navigation home__navigation">
      <%= live_patch link_body("Timeline","feather-activity"),
        to: "/my/timeline",
        class: if @selected_tab == "timeline", do: "navigation__item active", else: "navigation__item"
      %>
      <%= live_patch link_body("My Groups", "feather-users"),
            to: "/my/groups",
            class: if @selected_tab == "groups", do: "navigation__item active", else: "navigation__item"
          %>
      </div>
      <div class="mainContent__selected">
        <%= cond do %>
          <% @selected_tab == "timeline" -> %>
            <%= live_component(
                @socket,
                TimelineLive,
                current_user: @current_user,
                selected_tab: @selected_tab,
                id: :timeline,
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
