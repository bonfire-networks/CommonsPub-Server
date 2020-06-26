defmodule MoodleNetWeb.UserLive do
  alias MoodleNetWeb.Component.StoryPreviewLive
  alias MoodleNetWeb.Component.HeroProfileLive
  alias MoodleNetWeb.Component.NavigationProfileLive
  alias MoodleNetWeb.Component.HeaderLive
  alias MoodleNetWeb.Component.ActivityLive

  use MoodleNetWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, :selected, "about")}
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
        <%= live_component(
          @socket,
          HeroProfileLive,
          image: "https://home.next.moodle.net/uploads/01E9TQEVAKAVNZCQVE94NJA7TP/1_5XPNNG8qdFoHKABs0jvJMA.jpeg",
          icon: "https://home.next.moodle.net/uploads/01E9TQEVAKAVNZCQVE94NJA7TP/moebius4.jpeg",
          name: "Ivan Minutillo",
          username: "@ivan@pub.zo.team",
          website: "ivanminutillo.com",
          location: "Trivio, Formia",
          email: "bernini@inventati.org"
        )  %>
        <%= live_component(
            @socket,
            NavigationProfileLive,
            selected: @selected
          )
        %>

        <div class="mainContent__selected">
          <div class="selected__header">
            <h3>About</h3>
          </div>
          <div class="selected__area">
            <div class="markdown-body"></div>
          </div>
        </div>
      </div>

    </section>
    </div>

    """
  end

  def handle_event("show", %{"id" => id}, socket) do
      {:noreply, assign(socket, selected: id)}
  end

end
