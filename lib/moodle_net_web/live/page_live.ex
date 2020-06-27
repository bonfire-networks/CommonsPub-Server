defmodule MoodleNetWeb.PageLive do
  use MoodleNetWeb, :live_view

  @impl true

  def mount(%{current_user: current_user}, socket) do
    IO.inspect(live_mount_user: current_user)
    {:ok, assign_new(socket, :current_user, fn -> current_user end)}
  end

  def mount(_params, _session, socket) do
    IO.inspect(live_mount_params: _params)
    IO.inspect(live_mount_session: _session)
    {:ok, assign(socket, query: "", results: %{})}
  end

  @impl true
  def handle_event("suggest", %{"q" => query}, socket) do
    {:noreply, assign(socket, results: search(query), query: query)}
  end

  @impl true
  def handle_event("search", %{"q" => query}, socket) do
    case search(query) do
      %{^query => vsn} ->
        {:noreply, redirect(socket, external: "https://hexdocs.pm/#{query}/#{vsn}")}

      _ ->
        {:noreply,
         socket
         |> put_flash(:error, "No dependencies found matching \"#{query}\"")
         |> assign(results: %{}, query: query)}
    end
  end

  defp search(query) do
    if not MoodleNetWeb.Endpoint.config(:code_reloader) do
      raise "action disabled when not in development"
    end

    for {app, desc, vsn} <- Application.started_applications(),
        app = to_string(app),
        String.starts_with?(app, query) and not List.starts_with?(desc, ~c"ERTS"),
        into: %{},
        do: {app, vsn}
  end
end
