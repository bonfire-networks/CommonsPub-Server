defmodule CommonsPub.Web.Component.ContextLive do
  use CommonsPub.Web, :live_component



  def update(assigns, socket) do
    object = Bonfire.Repo.maybe_preload(assigns.object, :context)

    {:ok,
     assign(socket,
       object: object
     )}
  end
end
