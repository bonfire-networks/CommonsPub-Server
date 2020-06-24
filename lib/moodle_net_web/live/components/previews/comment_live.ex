defmodule MoodleNetWeb.Component.CommentPreviewLive do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~L"""
    <div class="comment__preview">
      <div class="markdown-body">
        <%= @comment.content %>
      </div>
    </div>
    """
  end
end
