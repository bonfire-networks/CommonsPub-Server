defmodule CommonsPub.Web.Component.StoryPreviewLive do
  use CommonsPub.Web, :live_component

  def render(assigns) do
    ~L"""
    <div class="story__preview">
      <div class="preview__info">
        <h2>Building a new app with rust</h2>
        <p>I used to love C and C++. If we date back to the mid 90’s, I did C, probably poor C++ which I thought was great, and Assembly exclusively as part of my reverse engineering/security work…</p>
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
        <div class="preview__time">
          3 days ago by ivanminutillo - 7 min read
        </div>
      </div>
      <div class="preview__icon" style="background-image: url('https://picsum.photos/200')"></div>
    </div>
    """
  end
end
