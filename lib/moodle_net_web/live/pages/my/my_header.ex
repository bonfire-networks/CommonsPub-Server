defmodule MoodleNetWeb.My.MyHeader do
  use MoodleNetWeb, :live_component

  import MoodleNetWeb.Helpers.Common

  # alias MoodleNetWeb.Helpers.{Profiles, Communities}

  def update(assigns, socket) do
    {
      :ok,
      socket
      |> assign(assigns)
    }
  end

  def handle_params(%{"signout" => name} = data, socket) do
    IO.inspect("signout!")
  end
end
