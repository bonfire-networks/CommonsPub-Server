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
      <%= live_patch to: "/!"<> e(@comment, :thread_id, "") <>"/discuss/"<> e(@comment, :id, "") do %>
          <button class="button"><i class="feather-message-square"></i> Reply</button>
          <% end %>
        <button class="button"><i class="feather-bookmark"></i> Bookmark</button>
        <details class="more__dropdown">
            <summary>
              <i class="feather-more-horizontal"></i>
            </summary>
            <ul class="dropdown__list">
              <li>
              <details class="dialog__container member">
              <summary class="button-link" >Report</summary>
              <dialog open class="dialog dialog__report">
                <header class="dialog__header">Report this comment</header>
                <section class="dialog__content">
                  <form>
                    <textarea placeholder="Describe the reason..."></textarea>
                    <footer class="dialog__footer">
                      <button value="default">Confirm</button>
                    </footer>
                  </form>
                </section>
              </dialog>
            </details>
              </li>
            </ul>
          </details>
      </div>
    </div>
    """
  end
end
