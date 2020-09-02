defmodule CommonsPub.Web.My.SidebarCommunitiesLive do
  use CommonsPub.Web, :live_component

  import CommonsPub.Web.Helpers.Common

  # alias CommonsPub.Web.Helpers.{Profiles, Communities}

  def update(assigns, socket) do
    {
      :ok,
      socket
      |> assign(assigns)
    }
  end
end
