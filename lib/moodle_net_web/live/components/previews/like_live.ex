defmodule MoodleNetWeb.Component.LikePreviewLive do
  use Phoenix.LiveComponent
  import MoodleNetWeb.Helpers.{Common}
  alias MoodleNetWeb.Helpers.Discussions
  alias MoodleNetWeb.Helpers.{Activites}

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
    like =  Activites.prepare(socket.assigns.comment)
    IO.inspect(like)
    c = Discussions.prepare_comment(like.context, socket.assigns.current_user)

    assign(socket,
      comment: c,
      current_user: assigns.current_user
    )
  end




  def render(assigns) do
    ~L"""
    <div id="<%= e(@comment, :id, "") %>" class="component__activity liked__activity">
      <div class="activity__info">
      <%= live_redirect to: "/@"<> e(@comment, :creator, :actor, :preferred_username, "deleted")  do %>
        <img src="<%= e(@comment, :creator, :icon_url, "") %>" alt="icon" />
      <% end %>
      <div class="info__meta">
        <div class="meta__action">
          <%= live_redirect to: "/@"<> e(@comment, :creator, :actor, :preferred_username, "deleted")  do %><%= e(@comment, :creator, :name, "Somebody") %><% end %>
          <p>
          <%= cond do %>
            <%= !is_nil(@comment.reply_to_id) and !is_nil(@comment.name) -> %>
              replied to:

              <%= @comment.reply_to_id -> %>
              replied to

              <%= @comment.name -> %>
              posted:

              <%= true -> %>
              started
          <% end %>
          </p>
        </div>
        <div class="meta__secondary">
          <%= e(@comment, :published_at, "one day") %>
        </div>
      </div>
      </div>
      <div class="activity__preview">
        <div class="comment__preview">
          <div class="markdown-body">
            <%= markdown(@comment.content) %>
          </div>
        </div>
      </div>
      </div>
    """
  end
end
