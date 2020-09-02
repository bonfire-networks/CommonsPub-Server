defmodule CommonsPub.Web.EditorLive do
  use CommonsPub.Web, :live_component

  import CommonsPub.Web.Helpers.Common

  def mount(socket) do
    {:ok, assign(socket, :editor, CommonsPub.Config.get(:ux)[:editor])}
  end
end
