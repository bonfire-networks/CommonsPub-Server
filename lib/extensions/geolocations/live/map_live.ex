defmodule MoodleNetWeb.Geolocation.MapLive do
  use MoodleNetWeb, :live_view

  import MoodleNetWeb.Helpers.Common

  @postgis_srid 4326

  def mount(params, session, socket) do
    socket = init_assigns(params, session, socket)

    {:ok,
     socket
     |> assign(page_title: "Map")}
  end

  def handle_params(%{"id" => id} = _params, _url, socket) when id != "" do
    show_place_things(id, socket)
  end

  def handle_params(_params, _url, socket) do
    fetch_places(socket)
  end

  def handle_event("marker_click", %{"id" => id} = _params, socket) do
    IO.inspect(click: id)

    {:noreply, socket |> push_redirect(to: "@@" <> id)}
  end

  def handle_event(
        "bounds",
        polygon,
        socket
      ) do
    IO.inspect(bounds: polygon)

    show_place_things(Enum.at(polygon, 0), socket)
  end

  # def handle_event("toggle_marker", %{"id" => id} = _params, socket) do
  #   {id, _} = Integer.parse(id)

  #   updated_markers =
  #     Enum.map(socket.assigns.markers, fn m ->
  #       case m.id do
  #         ^id ->
  #           Map.update(m, :is_disabled, m.is_disabled, &(!&1))

  #         _ ->
  #           m
  #       end
  #     end)

  #   {:noreply, assign(socket, markers: updated_markers)}
  # end

  def get_icon_url(false) do
    "/images/logo_commonspub.png"
  end

  def get_icon_url(_) do
    "/images/sun_face.png"
  end

  defp fetch_places(socket) do
    with {:ok, places} <-
           Geolocation.GraphQL.geolocations(%{limit: 15}, %{
             context: %{current_user: socket.assigns.current_user}
           }) do
      # [
      #   %{id: 1, lat: 51.5, long: -0.09, selected: false},
      #   %{id: 2, lat: 51.5, long: -0.099, selected: true}
      # ]

      mark_places(socket, places.edges)
    else
      _e ->
        {:noreply, socket}
    end
  end

  defp show_place_things("intents", socket) do
    fetch_place_things([preload: :at_location], socket)
  end

  defp show_place_things(id, socket) when is_binary(id) do
    fetch_place_things([at_location: id], socket)
  end

  defp show_place_things(
         polygon,
         socket
       ) do
    polygon = Enum.map(polygon, &Map.values(&1))
    polygon = Enum.map(polygon, &{List.first(&1), List.last(&1)})
    polygon = polygon ++ [List.first(polygon)]

    IO.inspect(polygon)

    geom = %Geo.Polygon{
      coordinates: [polygon],
      srid: @postgis_srid
    }

    IO.inspect(geom)

    fetch_place_things([location_within: geom], socket)
  end

  defp fetch_place_things(filters, socket) do
    with {:ok, things} <-
           ValueFlows.Planning.Intent.Intents.many(filters) do
      IO.inspect(things)

      things =
        things
        |> Enum.map(
          &Map.merge(
            Geolocation.Geolocations.populate_coordinates(Map.get(&1, :at_location)),
            &1 || %{}
          )
        )

      IO.inspect(things)

      mark_places(socket, things, nil)
    else
      _e ->
        fetch_places(socket)
    end
  end

  defp fetch_place(id, socket) do
    with {:ok, place} <-
           Geolocation.GraphQL.geolocation(%{id: id}, %{
             context: %{current_user: socket.assigns.current_user}
           }) do
      mark_places(socket, [place], place)
    else
      _e ->
        {:noreply, socket}
    end
  end

  defp mark_places(socket, places, place \\ nil) do
    IO.inspect(places)

    points = Enum.map(places, &[Map.get(&1, :lat, 0), Map.get(&1, :long, 0)])
    IO.inspect(points)

    {:noreply,
     assign(socket,
       markers: places,
       points: points,
       place: place
     )}
  end
end
