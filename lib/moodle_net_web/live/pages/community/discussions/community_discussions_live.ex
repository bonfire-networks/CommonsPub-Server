defmodule MoodleNetWeb.CommunityLive.CommunityDiscussionsLive do
  use MoodleNetWeb, :live_component

  alias MoodleNetWeb.GraphQL.{
    CommunitiesResolver
  }
  alias MoodleNetWeb.Component.{
    DiscussionPreviewLive
  }



  def update(assigns, socket) do
    # IO.inspect(assigns, label: "ASSIGNS:")
    {
      :ok,
      socket
      |> assign(assigns)
      |> fetch(assigns)
    }
  end

  defp fetch(socket, assigns) do
    # IO.inspect(after: assigns.after)

    {:ok, threads} = MoodleNetWeb.GraphQL.ThreadsResolver.threads_edge(
        %{id: assigns.community.id},
        %{limit: 3},
        %{context: %{current_user: assigns.current_user}}
      )


     IO.inspect(threads, label: "Threads COMMUNITY:")

    assign(socket,
      threads: threads.edges,
      has_next_page: threads.page_info.has_next_page,
      after: threads.page_info.end_cursor,
      before: threads.page_info.start_cursor
    )
  end

  def handle_event("load-more", _, %{assigns: assigns} = socket) do
    {:noreply, socket |> assign(page: assigns.page + 1) |> fetch(assigns)}
  end


end
