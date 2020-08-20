defmodule MoodleNetWeb.Geolocation.MapLive do
  use MoodleNetWeb, :live_view

  import MoodleNetWeb.Helpers.Common

  @impl true
  def mount(params, session, socket) do
    socket = init_assigns(params, session, socket)

    fetch_markers(socket)
  end

  @impl true
  def handle_event("toggle_marker", %{"id" => id} = _params, socket) do
    {id, _} = Integer.parse(id)

    updated_markers =
      Enum.map(socket.assigns.markers, fn m ->
        case m.id do
          ^id ->
            Map.update(m, :is_disabled, m.is_disabled, &(!&1))

          _ ->
            m
        end
      end)

    {:noreply, assign(socket, markers: updated_markers)}
  end

  def get_icon_url(false) do
    "/images/logo_commonspub.png"
  end

  def get_icon_url(_) do
    "/images/sun_face.png"
  end

  defp fetch_markers(socket) do
    with {:ok, places} <-
           Geolocation.GraphQL.geolocations(%{limit: 15}, %{
             context: %{current_user: socket.assigns.current_user}
           }) do
      IO.inspect(places)

      # [
      #   %{id: 1, lat: 51.5, long: -0.09, selected: false},
      #   %{id: 2, lat: 51.5, long: -0.099, selected: true}
      # ]

      points = Enum.map(places.edges, &[&1.lat, &1.long])
      IO.inspect(points)

      {:ok,
       assign(socket,
         markers: places.edges,
         points: points
       )}
    else
      _e ->
        []
    end
  end
end
