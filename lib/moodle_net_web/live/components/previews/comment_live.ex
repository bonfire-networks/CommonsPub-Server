defmodule MoodleNetWeb.Component.CommentPreviewLive do
  use Phoenix.LiveComponent
  import MoodleNetWeb.Helpers.Common

  def render(assigns) do
    ~L"""
    <div class="comment__preview">
      <div class="markdown-body">
        <%= markdown(@comment.content) %>
      </div>
      <div class="preview__actions">
        <button class="button"><i class="feather-message-square"></i> Reply</button>
        <button class="button"><i class="feather-bookmark"></i> Bookmark</button>
        <details class="more__dropdown">
            <summary>
              <i class="feather-more-horizontal"></i>
            </summary>
            <ul class="dropdown__list">
              <li><button class="button-link" >Report</button></li>
            </ul>
          </details>
      </div>
    </div>
    """
  end
end
