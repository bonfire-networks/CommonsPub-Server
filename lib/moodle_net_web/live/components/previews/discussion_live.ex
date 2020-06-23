defmodule MoodleNetWeb.Component.DiscussionPreviewLive do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~L"""
    <div class="discussion__preview">
      <h2 class="discussion__title">Do we really need Motivational design?</h2>
      <div class="discussion__meta">
        <div class="meta__time">
          Started 3 days ago by ivan
        </div>
        <div class="preview__meta">
          <div class="meta__item">
            <i class="feather-message-square"></i>
            5
          </div>
          <div class="meta__item">
            <i class="feather-star"></i>
            13
          </div>
        </div>
      </div>
    </div>
    """
  end
end
