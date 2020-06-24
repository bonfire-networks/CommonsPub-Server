defmodule MoodleNetWeb.Component.CommunityPreviewLive do
  use Phoenix.LiveComponent

  def mount(community, _, socket) do
    {:ok, assign(socket, community: community)}
  end

  def render(assigns) do
    ~L"""
    <a href="/community/<%= @community.id %>">
      <div class="community__preview">
        <div class="preview__image" style="background-image: url()"></div>
        <div class="preview__info">
          <h3><%= @community.name %></h3>
        </div>
      </div>
    </a>
    """
  end
end
