defmodule MoodleNetWeb.Component.UserPreviewLive do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~L"""
    <a href="/@<%= @user.actor.preferred_username %>">
      <div class="user__preview">
        <div class="preview__image" style="background-image: url()"></div>
        <div class="preview__info">
          <h3><%= @user.name %></h3>
          <h4>@<%= @user.actor.preferred_username %></h4>
        </div>
      </div>
    </a>
    """
  end
end
