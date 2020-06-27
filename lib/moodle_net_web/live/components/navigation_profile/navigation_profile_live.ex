defmodule MoodleNetWeb.Component.NavigationProfileLive do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~L"""
    <div class="mainContent__navigation">
    <a
      href="/@<%= @username %>/about"
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
      href="/@<%= @username %>/timeline"
      class="navigation__item <%= if "timeline" == @selected, do: "active" %>">
      <i class="feather-activity"></i>
      Timeline</a>
    <a
      phx-click="show"
      phx-value-id="stories"
      href="/@<%= @username %>/stories"
      class="navigation__item <%= if "stories" == @selected, do: "active" %>">
      <i class="feather-file-text"></i>
      Stories</a>
    <a
      phx-click="show"
      phx-value-id="discussions"
      href="/@<%= @username %>/discussions"
      class="navigation__item <%= if "discussions" == @selected, do: "active" %>">
      <i class="feather-message-square"></i>
      Discussions</a>
    </div>
    """
  end
end
