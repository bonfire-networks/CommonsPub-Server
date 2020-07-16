defmodule MoodleNetWeb.Component.UnknownPreviewLive do
  use Phoenix.LiveComponent

  import MoodleNetWeb.Helpers.Common

  def render(assigns) do
    ~L"""
    <div class="story__preview">
      <div class="preview__info">
        <h2><%= e(@object, :name, "") %></h2>
        <p><%= e(@object, :summary, "") %></p>
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
