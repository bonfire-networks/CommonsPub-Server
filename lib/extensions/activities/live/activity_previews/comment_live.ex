defmodule CommonsPub.Web.Component.CommentPreviewLive do
  use Phoenix.LiveComponent
  import CommonsPub.Utils.Web.CommonHelper
  # alias CommonsPub.Discussions.Web.DiscussionsHelper

  # def update(%{comment: _} = assigns, socket) do
  #   c = DiscussionsHelper.prepare_comment(assigns.comment, assigns.current_user)
  #   IO.inspect(update_comment: c)

  #   {
  #     :ok,
  #     socket
  #     |> assign(socket,
  #       comment: c,
  #       current_user: assigns.current_user
  #     )
  #   }
  # end

  # def mount(comment, _, socket) do
  #   {
  #     :ok,
  #     socket
  #     |> assign(socket,
  #       comment: comment
  #     )
  #   }
  # end

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
