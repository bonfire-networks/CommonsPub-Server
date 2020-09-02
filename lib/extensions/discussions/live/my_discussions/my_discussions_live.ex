defmodule CommonsPub.Web.My.MyDiscussionsLive do
  use CommonsPub.Web, :live_component

  # import CommonsPub.Web.Helpers.Common

  alias CommonsPub.Web.Component.{
    DiscussionPreviewLive
  }

  # alias CommonsPub.Web.Helpers.{Profiles}

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

  def fetch(socket, assigns) do
    # IO.inspect(assigns.user)
    page_opts = %{limit: 20, after: assigns.after}
    IO.inspect(page_opts)

    opts = [user: assigns.current_user, creator_or_participant: assigns.current_user.id]

    filters = [
      page: [desc: [last_comment: page_opts]]
    ]

    {:ok, threads} =
      CommonsPub.Web.GraphQL.ThreadsResolver.list_creator_threads(
        page_opts,
        opts,
        filters,
        :last_comment
      )

    IO.inspect(threads)

    assign(socket,
      threads: threads.edges,
      has_next_page: threads.page_info.has_next_page,
      after: threads.page_info.end_cursor,
      before: threads.page_info.start_cursor,
      current_user: assigns.current_user
    )
  end

  # TODO: pagination
  # def handle_event("load-more", _, socket), do: CommonsPub.Web.Helpers.Common.paginate_next(&fetch/2, socket)
end
