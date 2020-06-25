defmodule MoodleNetWeb.DiscoverLive do
  use MoodleNetWeb, :live_view
  alias MoodleNetWeb.Component.HeaderLive

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
      <div class="instance__hero">
        <h1>Fediverse</h1>
      </div>
      <div class="mainContent__navigation home__navigation">
        <a href="#" class="navigation__item active">
          <i class="feather-activity"></i>Timeline
        </a>
        <a href="#" class="navigation__item">
        <i class="feather-file-text"></i>
        Stories
        </a>
        <a href="#" class="navigation__item">
        <i class="feather-message-square"></i>
          Discussions
        </a>
      </div>
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

end
