defmodule MoodleNetWeb.SearchLive.Form do
  use MoodleNetWeb, :live_component

  import MoodleNetWeb.Helpers.Common

  def handle_event("search", params, %{assigns: assigns} = socket) do
    IO.inspect(params)

    {:noreply,
     socket |> push_patch(to: "/instance/search/all/" <> params["search_field"]["query"])}
  end
end
