defmodule MoodleNetWeb.DiscussionLive do
  use MoodleNetWeb, :live_view
  import MoodleNetWeb.Helpers.Common
  alias MoodleNetWeb.GraphQL.{ThreadsResolver, CommentsResolver}

  alias MoodleNetWeb.Helpers.{
    # Account,
    Discussions
  }

  alias MoodleNetWeb.Discussion.DiscussionCommentLive

  def mount(%{"id" => thread_id} = params, session, socket) do
    socket = init_assigns(params, session, socket)

    current_user = socket.assigns.current_user

    {:ok, thread} =
      ThreadsResolver.thread(%{thread_id: thread_id}, %{
        context: %{current_user: current_user}
      })

    thread = Discussions.prepare_thread(thread)

    # IO.inspect(thread, label: "THREAD")

    # TODO: tree of replies & pagination
    {:ok, comments} =
      CommentsResolver.comments_edge(thread, %{limit: 10}, %{
        context: %{current_user: current_user}
      })

    comments_edges = Discussions.prepare_comments(comments.edges)

    # IO.inspect(comments_edges, label: "COMMENTS")

    # tree = build_comment_thread_1(comments_edges)
    tree = build_comment_thread_2(comments_edges)

    # IO.inspect(tree: tree)

    # [head | tail] = tree
    # {id, main_comment} = Enum.fetch!(tree, 0)

    # IO.inspect(main_comment: main_comment)

    {:ok,
     assign(socket,
       #  current_user: current_user,
       reply_to: nil,
       thread: thread,
       #  main_comment: main_comment,
       comments: tree
     )}
  end

  def build_comment_thread_1(comments) do
    comments
    |> Enum.reverse()
    |> Enum.reduce(%{}, fn foo, map ->
      foo = %{foo | comments: Map.get(map, foo.id, [])}
      Map.update(map, foo.reply_to_id, [foo], fn foos -> [foo | foos] end)
    end)
    |> Map.get(nil)
    |> hd
  end

  def build_comment_thread_2(comments) do
    comments =
      comments
      |> Enum.reverse()
      |> Enum.map(&Map.from_struct/1)

    lum = Enum.reduce(comments, %{}, &Map.put(&2, &1.id, &1))

    # IO.inspect(lum)

    comments
    |> Enum.reduce(lum, fn
      %{reply_to_id: nil} = comment, acc ->
        acc

      comment, acc ->
        # IO.inspect(acc: acc)
        # IO.inspect(comment: comment)

        acc
        |> update_in([comment.reply_to_id, :comments], &[acc[comment.id] | &1])
        |> Map.delete(comment.id)
    end)
  end

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
    {:noreply,
     assign(socket,
       reply_to: nil
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

      reply_to_id =
        if !is_nil(socket.assigns.reply_to) do
          socket.assigns.reply_to
        else
          socket.assigns.main_comment.id
        end

      {:ok, comment} =
        MoodleNetWeb.GraphQL.CommentsResolver.create_reply(
          %{
            thread_id: socket.assigns.thread.id,
            in_reply_to_id: reply_to_id,
            comment: comment
          },
          %{context: %{current_user: socket.assigns.current_user}}
        )

      # IO.inspect(comment)
      # TODO: error handling

      {:noreply,
       socket
       #  |> put_flash(:info, "Replied!")
       # redirect in order to reload comments, TODO: just add comment which was returned by resolver?
       |> push_redirect(to: "/!" <> socket.assigns.thread.id <> "/discuss" <> comment.id)}
    end
  end
end
