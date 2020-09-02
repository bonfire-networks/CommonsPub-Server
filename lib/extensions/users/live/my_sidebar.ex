defmodule CommonsPub.Web.My.MySidebar do
  use CommonsPub.Web, :live_component

  import CommonsPub.Web.Helpers.Common

  def update(assigns, socket) do
    {
      :ok,
      socket
      |> assign(assigns)
    }
  end
end
