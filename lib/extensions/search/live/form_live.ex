defmodule CommonsPub.Web.SearchLive.Form do
  use CommonsPub.Web, :live_component

  # import CommonsPub.Utils.Web.CommonHelper

  def handle_event("search", params, %{assigns: _assigns} = socket) do
    IO.inspect(search: params)
    IO.inspect(socket)

    if(socket.view == CommonsPub.Web.SearchLive) do
      {:noreply,
       socket |> push_patch(to: "/instance/search/all/" <> params["search_field"]["query"])}
    else
      {:noreply,
       socket |> push_redirect(to: "/instance/search/all/" <> params["search_field"]["query"])}
    end
  end
end
