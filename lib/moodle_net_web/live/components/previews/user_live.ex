defmodule MoodleNetWeb.Component.UserPreviewLive do
  use Phoenix.LiveComponent
  import MoodleNetWeb.Helpers.Common
  alias MoodleNetWeb.Helpers.{Profiles}

  def update(assigns, socket) do
    {:ok, assign(socket, user: Profiles.prepare(assigns.user))}
  end

  def render(assigns) do
    ~L"""
    <a href="/@<%= @user.actor.preferred_username %>">
      <div class="user__preview">
        <div class="preview__image" style="background-image: url(<%= e(@user, :icon, "") %>)"></div>
        <div class="preview__info">
          <h3><%= @user.name %></h3>
          <h4>@<%= @user.actor.preferred_username %></h4>
        </div>
      </div>
    </a>
    """
  end
end
