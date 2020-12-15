defmodule CommonsPub.Web.MemberLive.MemberDiscussionsLive do
  use CommonsPub.Web, :live_component

  #

  alias CommonsPub.Web.Component.{
    DiscussionPreviewLive
  }

  # alias CommonsPub.Profiles.Web.ProfilesHelper

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

    page_opts = %{limit: 10}

    opts = [user: assigns.current_user, creator: assigns.user.id]

    filters = [
      page: [desc: [created: page_opts]]
      # join: :first_comment,
      # preload: :first_comment
    ]

    {:ok, threads} =
      CommonsPub.Web.GraphQL.ThreadsResolver.list_creator_threads(
        page_opts,
        opts,
        filters,
        [:created]
      )

    # CommonsPub.Web.GraphQL.ThreadsResolver.creator_threads_edge(
    #   %{creator: assigns.user.id},
    #   %{limit: 3},
    #   %{context: %{current_user: assigns.current_user},
    # }
    # )

    # IO.inspect(threads)

    assign(socket,
      threads: threads.edges,
      has_next_page: threads.page_info.has_next_page,
      after: threads.page_info.end_cursor,
      before: threads.page_info.start_cursor,
      current_user: assigns.current_user
    )
  end

  def handle_event("load-more", _, socket),
    do: CommonsPub.Utils.Web.CommonHelper.paginate_next(&fetch/2, socket)
end
