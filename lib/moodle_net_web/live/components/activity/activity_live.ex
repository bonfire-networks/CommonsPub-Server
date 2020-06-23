defmodule MoodleNetWeb.Component.ActivityLive do
  use Phoenix.LiveComponent
  alias MoodleNetWeb.Component.StoryPreviewLive
  alias MoodleNetWeb.Component.CommentPreviewLive

  def render(assigns) do
    ~L"""
    <div class="component__activity">
      <div class="activity__info">
        <img src="https://docs.moodle.org/dev/images_dev/thumb/2/2b/estrella.jpg/100px-estrella.jpg" alt="icon" />
        <div class="info__meta">
          <div class="meta__action">
            <a href="#">Estrella</a>
            <p>published a new story</p>
          </div>
          <div class="meta__secondary">
            1 year ago - <a href="#">CommunityName</a>
          </div>
        </div>
      </div>
      <div class="activity__preview">
        <%= live_component(
          @socket,
          CommentPreviewLive
        )  %>
      </div>
    </div>
    """
  end
end
