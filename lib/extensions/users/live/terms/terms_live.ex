defmodule CommonsPub.Web.TermsLive do
  use CommonsPub.Web, :live_view
  import CommonsPub.Web.Helpers.Common

  def mount(params, session, socket) do
    socket = init_assigns(params, session, socket)

    {:ok,
     socket
     |> assign(app_name: Application.get_env(:commons_pub, :app_name))}
  end
end
