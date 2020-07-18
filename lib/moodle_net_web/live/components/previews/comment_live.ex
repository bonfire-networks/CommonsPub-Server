defmodule MoodleNetWeb.Component.CommentPreviewLive do
  use Phoenix.LiveComponent
  import MoodleNetWeb.Helpers.{Common}
  alias MoodleNetWeb.Helpers.Discussions

  # def update(%{comment: _} = assigns, socket) do
  #   c = Discussions.prepare_comment(assigns.comment, assigns.current_user)
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

  def handle_event("flag", %{"message" => message} = _args, socket) do
    {:ok, flag} =
      MoodleNetWeb.GraphQL.FlagsResolver.create_flag(
        %{context_id: socket.assigns.comment.id, message: message},
        %{
          context: %{current_user: socket.assigns.current_user}
        }
      )

    IO.inspect(flag, label: "FLAG")

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
        <button phx-click="like" phx-target="<%= @myself %>" class="button-link"><%= if e(@comment, :is_liked, false), do: 'Unlike', else: 'Like' %></button>
        <details class="dialog__container member">
        <summary class="button-link" >Report</summary>
        <dialog open class="dialog dialog__report">
          <header class="dialog__header">Report this comment</header>
          <section class="dialog__content">
            <form method="post" phx-submit="flag" phx-target="<%= @myself %>">
              <textarea name="message" placeholder="Describe the reason..."></textarea>
              <footer class="dialog__footer">
                <button type="submit" phx-disable-with="Checking..." value="default">Confirm</button>
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
