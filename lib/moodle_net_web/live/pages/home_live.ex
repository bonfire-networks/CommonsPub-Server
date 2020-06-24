defmodule MoodleNetWeb.HomeLive do
  use MoodleNetWeb, :live_view
  alias MoodleNetWeb.Component.HeaderLive
  alias MoodleNetWeb.GraphQL.CommunitiesResolver

  def mount(_params, _session, socket) do

    {:ok, assign(socket, :feed, CommunitiesResolver.communities(%{}, %{}))}
  end

  def render(assigns) do
    instance = MoodleNet.Instance.hostname
    IO.inspect(@feed)
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
        <h1>My instance</h1>
        <h4>@<%=instance%></h4>
      </div>
      <div class="mainContent__navigation home__navigation">
        <a href="#" class="navigation__item">
          <i class="feather-heart"></i>About
        </a>
        <a href="#" class="navigation__item active">
          <i class="feather-activity"></i>Timeline
        </a>
        <a href="#" class="navigation__item">
          <i class="feather-file-text"></i>
          Members
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
