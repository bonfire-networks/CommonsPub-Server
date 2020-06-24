defmodule MoodleNetWeb.Component.HeaderLive do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~L"""
      <header class="page__header">
      <div class="header__left">
        <a href="/">
          <img src="./images/sun_face.png" alt="logo" />
        </a>
        <input placeholder="Search..." />
      </div>
      <div class="header__right">
        <a class="button button-clear right__discover" href="/discover">Discover</a>
        <a class="button" href="/write"><i class="feather-file-text"></i> New story</a>
        <div class="header__avatar">
          <a href="/me"><img src="<%= @icon %>" /></a>
        </div>
      </div>
      </header>
    """
  end
end
