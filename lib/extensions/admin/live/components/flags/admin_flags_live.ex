defmodule MoodleNetWeb.AdminLive.AdminFlagsLive do
  use MoodleNetWeb, :live_component
  alias MoodleNetWeb.GraphQL.FlagsResolver

  def mount(socket) do
    {
      :ok,
      socket
      |> assign(page: 1)
    }
  end

  def update(assigns, socket) do
    {
      :ok,
      socket
      |> assign(assigns)
      |> fetch(assigns)
    }
  end

  def fetch(socket, assigns) do
    {:ok, flags} =
      FlagsResolver.flags(
        %{after: [], limit: 10},
        %{context: %{current_user: assigns.current_user}}
      )

    IO.inspect(flags, label: "FLAGS")

    activities =
      Enum.map(
        flags.edges,
        &flag_to_activity/1
      )

    IO.inspect(activities, label: "FLAGS_activities")

    assign(socket,
      activities: activities,
      has_next_page: flags.page_info.has_next_page,
      after: flags.page_info.end_cursor,
      before: flags.page_info.start_cursor
    )
  end

  defp flag_to_activity(flag) do
    flag
    |> Map.merge(%{
      context: flag,
      verb: "flag"
    })
  end

  def handle_event("load-more", _, socket),
    do: MoodleNetWeb.Helpers.Common.paginate_next(&fetch/2, socket)
end
