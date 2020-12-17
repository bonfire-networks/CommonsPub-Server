defmodule CommonsPub.Web.TermsLive do
  use CommonsPub.Web, :live_view


  def mount(params, session, socket) do
    socket = init_assigns(params, session, socket)

    {:ok,
     socket
     |> assign(app_name: Bonfire.Common.Config.get(:app_name))}
  end
end
