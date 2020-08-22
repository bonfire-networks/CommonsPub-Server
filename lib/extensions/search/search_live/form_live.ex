defmodule MoodleNetWeb.SearchLive.Form do
  use MoodleNetWeb, :live_component

  import MoodleNetWeb.Helpers.Common

  def handle_event("search", params, %{assigns: assigns} = socket) do
    IO.inspect(search: params)
    IO.inspect(socket)

    if(socket.view == MoodleNetWeb.SearchLive) do
      {:noreply,
       socket |> push_patch(to: "/instance/search/all/" <> params["search_field"]["query"])}
    else
      {:noreply,
       socket |> push_redirect(to: "/instance/search/all/" <> params["search_field"]["query"])}
    end
  end
end
