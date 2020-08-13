defmodule MoodleNetWeb.SettingsLive.SettingsFlagsLive do
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

  defp fetch(socket, assigns) do
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

  def handle_event("load-more", _, %{assigns: assigns} = socket) do
    {:noreply, socket |> assign(page: assigns.page + 1) |> fetch(assigns)}
  end

  def render(assigns) do
    ~L"""
    <section class="settings__section">
        <div class="section__main">
          <h1>Flags</h1>

          <%= live_component(
            @socket,
            MoodleNetWeb.Component.ActivitiesListLive,
            assigns
            )
          %>

        </div>
      </section>
    """
  end
end
