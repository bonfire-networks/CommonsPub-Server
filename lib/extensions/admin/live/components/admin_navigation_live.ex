defmodule MoodleNetWeb.AdminLive.AdminNavigationLive do
  use MoodleNetWeb, :live_component

  def render(assigns) do
    ~L"""
    <%= live_patch link_body("Manage access", "feather-users"),
      to: "/admin/settings/access",
      class: if @selected == "access", do: "navigation__item active", else: "navigation__item"
    %>
    <%= live_patch link_body("flags", "feather-flag"),
      to: "/admin/settings/flags",
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
