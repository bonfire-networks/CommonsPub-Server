defmodule MoodleNetWeb.DiscussionLive do
  use MoodleNetWeb, :live_view
  import MoodleNetWeb.Helpers.Common
  alias MoodleNetWeb.GraphQL.{ThreadsResolver, CommentsResolver}

  alias MoodleNetWeb.Helpers.{
    # Account,
    Discussions
  }

  # alias MoodleNetWeb.Component.{CommentPreviewLive}
  alias MoodleNetWeb.Discussion.DiscussionCommentLive

  def mount(%{"id" => thread_id} = params, session, socket) do
    socket = init_assigns(params, session, socket)
    {:ok, socket}
  end

  # def handle_params(%{"id" => thread_id, "do" => "discuss"} = params, session, socket) do
  #   {:ok,
  #   socket
  #   |> push_redirect(to: "/!" <> thread_id <> "/discuss")}
  # end

  def handle_params(
        %{"id" => thread_id, "sub_id" => comment_id} = params,
        session,
        socket
      ) do
    {:noreply,
     assign(socket,
       reply_to: comment_id
     )}
  end

  def handle_params(%{"id" => thread_id} = params, session, socket) do
    current_user = socket.assigns.current_user

    {:ok, thread} =
      ThreadsResolver.thread(%{thread_id: thread_id}, %{
        context: %{current_user: current_user}
      })

    thread = Discussions.prepare_thread(thread)

    # IO.inspect(thread, label: "THREAD")

    # TODO: tree of replies & pagination
    {:ok, comments} =
      CommentsResolver.comments_edge(thread, %{}, %{
        context: %{current_user: current_user}
      })

    comments_edges = Discussions.prepare_comments(comments.edges)

    IO.inspect(comments_edges, label: "COMMENTS")

    [head | tail] = comments_edges

    {:noreply,
     assign(socket,
       #  current_user: current_user,
       reply_to: nil,
       thread: thread,
       main_comment: head,
       comments: tail
     )}
  end

  def handle_event("reply", %{"content" => content} = data, socket) do
    IO.inspect(data, label: "DATA")

    if(is_nil(content) or is_nil(socket.assigns.current_user)) do
      {:noreply,
       socket
       |> put_flash(:error, "Please write something...")}
    else
      # MoodleNetWeb.Plugs.Auth.login(socket, session.current_user, session.token)

      comment = input_to_atoms(data)

      _comment =
        MoodleNetWeb.GraphQL.CommentsResolver.create_reply(
          %{
            thread_id: socket.assigns.thread.id,
            in_reply_to_id: socket.assigns.main_comment.id,
            comment: comment
          },
          %{context: %{current_user: socket.assigns.current_user}}
        )

      {:noreply,
       socket
       #  |> put_flash(:info, "Replied!")
       |> push_patch(to: "/!" <> socket.assigns.thread.id <> "/discuss")}
    end
  end
end
