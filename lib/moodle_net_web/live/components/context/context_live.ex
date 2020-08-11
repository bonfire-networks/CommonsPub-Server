defmodule MoodleNetWeb.Component.ContextLive do
  use MoodleNetWeb, :live_component

  import MoodleNetWeb.Helpers.Common

  def update(assigns, socket) do
    object = maybe_preload(assigns.object, :context)

    {:ok,
     assign(socket,
       object: object
     )}
  end
end
