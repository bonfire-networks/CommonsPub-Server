defmodule CommonsPub.Web.MySidebar do
  use CommonsPub.Web, :live_component


  def update(assigns, socket) do
    {
      :ok,
      socket
      |> assign(assigns)
    }
  end
end
