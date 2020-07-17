defmodule MoodleNetWeb.Component.CommentPreviewLive do
  use Phoenix.LiveComponent
  import MoodleNetWeb.Helpers.{Common}
  alias MoodleNetWeb.Helpers.Discussions

  # def mount(params, session, socket) do
  #   comment = Discussions.prepare_comment(socket.assigns.comment, socket.assigns.current_user)
  #   {:ok, socket
  #   |> assign(comment: comment,
  #   current_user: socket.assigns.current_user)}
  # end

  def update(assigns, socket) do
    {
      :ok,
      socket
      |> assign(assigns)
      |> fetch(assigns)
    }
  end

  defp fetch(socket, assigns) do
    # IO.inspect(inbox_for: assigns.current_user)
    IO.inspect(c: socket.assigns.comment)
    c = Discussions.prepare_comment(socket.assigns.comment, socket.assigns.current_user)

    assign(socket,
      comment: c,
      current_user: assigns.current_user
    )
  end

  def handle_event("like", _data, socket) do
    {:ok, like} =
      MoodleNetWeb.GraphQL.LikesResolver.create_like(%{context_id: socket.assigns.comment.id}, %{
        context: %{current_user: socket.assigns.current_user}
      })

    IO.inspect(like, label: "LIKE")

    # IO.inspect(f)
    # TODO: error handling

    {
      :noreply,
      socket
      |> put_flash(:info, "Liked!")
      # |> assign(community: socket.assigns.comment |> Map.merge(%{is_liked: true}))
      #  |> push_patch(to: "/&" <> socket.assigns.community.username)
    }
  end

  def render(assigns) do
    ~L"""
    <div class="comment__preview">
      <div class="markdown-body">
        <%= markdown(@comment.content) %>
      </div>
      <div class="preview__actions">
        <%= live_patch to: "/!"<> e(@comment, :thread_id, e(@comment, :thread, :id, "")) <>"/discuss/"<> e(@comment, :id, "")<>"#reply" do %>
          <button class="button-link"><i class="feather-message-square"></i><span>Reply</span></button>
        <% end %>
        <button phx-click="like" phx-target="<%= @myself %>" class="button-link"><i class="feather-star <%= if e(@comment, :is_liked, false), do: 'liked', else: '' %>"></i><span><%= if e(@comment, :is_liked, false), do: 'Unlike', else: 'Like' %></i></span></button>
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
      </div>
    </div>
    """
  end
end
