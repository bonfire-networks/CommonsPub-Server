defmodule MoodleNetWeb.MemberLive.MemberDiscussionsLive do
  use MoodleNetWeb, :live_component

  import MoodleNetWeb.Helpers.Common

  alias MoodleNetWeb.Component.{
    DiscussionLive
  }
  alias MoodleNetWeb.Helpers.{Profiles}

  def mount(socket) do
    {
      :ok,
      socket,
      temporary_assigns: [discussions: [], page: 1, has_next_page: false, after: [], before: []]
    }
  end

  def update(assigns, socket) do
    {
      :ok,
      socket
      |> assign(
        user: assigns.user
      )
      |> fetch()
    }
  end

  defp fetch(socket) do
    IO.inspect(socket.assigns.user)
    # TODO: replace with logged in user's inbox
    comments = user = Profiles.creator_threads_edge(%{creator: nil}, %{limit: 10}, socket.assigns.user)
    IO.inspect(comments)
    assign(socket,
      comments: [],
      # has_next_page: comments.page_info.has_next_page,
      # after: comments.page_info.end_cursor,
      # before: comments.page_info.start_cursor
    )
  end

  def handle_event("load-more", _, %{assigns: assigns} = socket) do
    {:noreply, socket |> assign(page: assigns.page + 1) |> fetch()}
  end


end
