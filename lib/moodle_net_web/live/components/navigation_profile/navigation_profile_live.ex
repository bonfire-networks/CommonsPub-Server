defmodule MoodleNetWeb.Component.NavigationProfileLive do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~L"""
    <div class="mainContent__navigation">
    <a
      href=""
      phx-click="show"
      phx-value-id="about"
      class="navigation__item <%= if "about" == @selected, do: "active" %>"
      >
      <i class="feather-user"></i>
      About
    </a>
    <a
      phx-click="show"
      phx-value-id="timeline"
      href="#"
      class="navigation__item <%= if "timeline" == @selected, do: "active" %>">
      <i class="feather-activity"></i>
      Timeline</a>
    <a
      phx-click="show"
      phx-value-id="stories"
      href="#"
      class="navigation__item <%= if "stories" == @selected, do: "active" %>">
      <i class="feather-file-text"></i>
      Stories</a>
    <a
      phx-click="show"
      phx-value-id="discussions"
      href="#"
      class="navigation__item <%= if "discussions" == @selected, do: "active" %>">
      <i class="feather-message-square"></i>
      Discussions</a>
  </div>
    """
  end
end
