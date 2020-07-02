defmodule MoodleNetWeb.DiscussionLive do
  use MoodleNetWeb, :live_view
  alias MoodleNetWeb.GraphQL.ThreadsResolver
  alias MoodleNetWeb.Helpers.{Account, Discussion}

  def mount(%{"id" => id}, session, socket) do
    current_user= Account.current_user_or(nil, session, %{icon: true, actor: true})
    {:ok, thread} = ThreadsResolver.thread(%{thread_id: id}, %{})
    thread = Discussion.prepare(thread)
    IO.inspect(thread, label: "THREAD")
    {:ok, assign(socket,
      current_user: current_user,
      thread: thread)
    }
  end

end
