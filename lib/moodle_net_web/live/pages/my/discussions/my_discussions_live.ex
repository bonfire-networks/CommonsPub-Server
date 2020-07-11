defmodule MoodleNetWeb.My.MyDiscussionsLive do
  use MoodleNetWeb, :live_component

  # import MoodleNetWeb.Helpers.Common

  alias MoodleNetWeb.Component.{
    DiscussionPreviewLive
  }

  # alias MoodleNetWeb.Helpers.{Profiles}

  # def mount(socket) do
  #   {
  #     :ok,
  #     socket,
  #     temporary_assigns: [discussions: [], page: 1, has_next_page: false, after: [], before: []]
  #   }
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
    # IO.inspect(assigns.user)
    page_opts = %{limit: 10}

    opts = [user: assigns.current_user, creator_or_participant: assigns.current_user.id]

    filters = [
      page: [desc: [last_comment: page_opts]]
      # join: :comments
      # preload: :first_comment
    ]

    {:ok, threads} =
      MoodleNetWeb.GraphQL.ThreadsResolver.list_creator_threads(
        page_opts,
        opts,
        filters
      )

    IO.inspect(threads)

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
