defmodule MoodleNetWeb.Component.CommentPreviewLive do
  use Phoenix.LiveComponent
  import MoodleNetWeb.Helpers.Common

  def render(assigns) do
    ~L"""
    <div class="comment__preview">
      <div class="markdown-body">
        <%= markdown(@comment.content) %>
      </div>
    </div>
    """
  end
end
