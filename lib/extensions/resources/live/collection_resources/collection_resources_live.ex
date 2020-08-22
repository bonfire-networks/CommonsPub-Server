defmodule MoodleNetWeb.CollectionLive.CollectionResourcesLive do
  use MoodleNetWeb, :live_component

  alias MoodleNetWeb.Component.{
    ResourcesListLive
  }

  alias MoodleNetWeb.GraphQL.{
    ResourcesResolver
  }

  # def mount(socket) do
  #   {
  #     :ok,
  #     socket,
  #     temporary_assigns: [
  #       activities: [],
  #       page: 1,
  #       has_next_page: false,
  #       after: [],
  #       before: [],
  #       pagination_target: "#instance-activities"
  #     ]
  #   }
  # end

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

    {:ok, resources} =
      ResourcesResolver.resources_edge(
        %{id: assigns.context_id},
        %{after: assigns.after, limit: 3},
        %{context: %{current_user: assigns.current_user}}
      )

    IO.inspect(resources, label: "RESOURCES:")

    assign(socket,
      resources: resources.edges,
      has_next_page: resources.page_info.has_next_page,
      after: resources.page_info.end_cursor,
      before: resources.page_info.start_cursor
    )
  end

  def handle_event("load-more", _, %{assigns: assigns} = socket) do
    {:noreply, socket |> assign(page: assigns.page + 1) |> fetch(assigns)}
  end

  def render(assigns) do
    ~L"""
    <div>
      <div class="community__discussion__actions">
        <%# <input placeholder="Search resources..."/> %>
        <a phx-target="#post_link" phx-click="toggle_link">
          <button >Share a link</button>
        </a>
      </div>
      <div id="collection-resources">
        <%= live_component(
          @socket,
          ResourcesListLive,
          assigns
          )
        %>
      </div>
    </div>
    """
  end
end
