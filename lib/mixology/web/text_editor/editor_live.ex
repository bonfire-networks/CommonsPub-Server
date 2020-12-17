defmodule CommonsPub.Web.EditorLive do
  use CommonsPub.Web, :live_component

  #

  def mount(socket) do
    {:ok, assign(socket, :editor, Bonfire.Common.Config.get(:ux)[:editor])}
  end
end
