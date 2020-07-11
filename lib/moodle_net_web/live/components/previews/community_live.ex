defmodule MoodleNetWeb.Component.CommunityPreviewLive do
  use Phoenix.LiveComponent
  import MoodleNetWeb.Helpers.Common

  def mount(community, _, socket) do
    {:ok, assign(socket, community: community)}
  end

  def render(assigns) do
    ~L"""
    <a href="/&<%= @community.actor.preferred_username %>">
      <div class="community__preview">
        <div class="preview__image" style="background-image: url(<%= e(@community, :icon_url, e(@community, :image_url, "")) %>)"></div>
        <div class="preview__info">
          <h3><%= e(@community, :name, "Community") %></h3>
        </div>
      </div>
    </a>
    """
  end
end
