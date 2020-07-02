defmodule MoodleNetWeb.DiscussionLive do
  use MoodleNetWeb, :live_view
  alias MoodleNetWeb.GraphQL.{ThreadsResolver, CommentsResolver}
  alias MoodleNetWeb.Helpers.{Account, Discussion}

  def mount(%{"id" => id}, session, socket) do
    current_user = Account.current_user_or(nil, session, %{icon: true, actor: true})

    {:ok, thread} =
      ThreadsResolver.thread(%{thread_id: id}, %{
        context: %{current_user: current_user}
      })

    thread = Discussion.prepare_thread(thread)
    IO.inspect(thread, label: "THREAD")

    {:ok, comments} =
      CommentsResolver.comments_edge(thread, %{}, %{
        context: %{current_user: current_user}
      })

    comments_edges = Enum.map(comments.edges, &Discussion.prepare_comment/1)
    IO.inspect(comments, label: "COMMENTS")

    {:ok,
     assign(socket,
       current_user: current_user,
       thread: thread,
       comments: comments_edges
     )}
  end
end
