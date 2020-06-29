defmodule MoodleNetWeb.MemberLive.MemberNavigationLive do
  use MoodleNetWeb, :live_component

  def render(assigns) do
    ~L"""
    <div class="mainContent__navigation">
    <%= live_patch link_body("About", "feather-book-open"),
      to: "/@" <> @username <> "/about",
      class: if @selected == "about", do: "navigation__item active", else: "navigation__item"
    %>
    <%= live_patch link_body("Timeline", "feather-activity"),
      to: "/@" <> @username <> "/timeline",
      class: if @selected == "timeline", do: "navigation__item active", else: "navigation__item"
    %>
    <%= live_patch link_body("Likes", "feather-file-text"),
      to: "/@" <> @username <> "/likes",
      class: if @selected == "likes", do: "navigation__item active", else: "navigation__item"
    %>
    <%= live_patch link_body("Discussion", "feather-message-square"),
      to: "/@" <> @username <> "/discussions",
      class: if @selected == "discussions", do: "navigation__item active", else: "navigation__item"
      %>
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
