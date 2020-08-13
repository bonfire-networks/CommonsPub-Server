defmodule MoodleNetWeb.My.MySidebar do
  use MoodleNetWeb, :live_component

  import MoodleNetWeb.Helpers.Common


  def update(assigns, socket) do
    {
      :ok,
      socket
      |> assign(assigns)
    }
  end


end
