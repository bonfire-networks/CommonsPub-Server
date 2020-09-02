defmodule CommonsPub.Web.Component.ContextLive do
  use CommonsPub.Web, :live_component

  import CommonsPub.Web.Helpers.Common

  def update(assigns, socket) do
    object = maybe_preload(assigns.object, :context)

    {:ok,
     assign(socket,
       object: object
     )}
  end
end
