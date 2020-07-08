defmodule MoodleNetWeb.SettingsLive.SettingsNavigationLive do
  use MoodleNetWeb, :live_component

  def render(assigns) do
    ~L"""
    <%= live_patch link_body("General", "feather-settings"),
      to: "/my/settings/general",
      class: if @selected == "general", do: "navigation__item active", else: "navigation__item"
    %>
    <%= live_patch link_body("Preferences", "feather-sliders"),
      to: "/my/settings/preferences",
      class: if @selected == "preferences", do: "navigation__item active", else: "navigation__item"
    %>
    <h4 class="navigation__title">Admin</h4>
    <%= live_patch link_body("instance", "feather-droplet"),
      to: "/my/settings/instance",
      class: if @selected == "instance", do: "navigation__item active", else: "navigation__item"
    %>
    <%= live_patch link_body("invites", "feather-mail"),
      to: "/my/settings/invites",
      class: if @selected == "invites", do: "navigation__item active", else: "navigation__item"
    %>
    <%= live_patch link_body("flags", "feather-flag"),
      to: "/my/settings/flags",
      class: if @selected == "flags", do: "navigation__item active", else: "navigation__item"
    %>
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
