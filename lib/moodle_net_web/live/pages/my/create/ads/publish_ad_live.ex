defmodule MoodleNetWeb.My.PublishAdLive do
  use MoodleNetWeb, :live_component

  import MoodleNetWeb.Helpers.Common

  alias ValueFlows.Planning.Intent.GraphQL
  # alias MoodleNetWeb.Helpers.{Profiles, Communities}

  def update(assigns, socket) do
    {
      :ok,
      socket
      |> assign(assigns)
    }
  end

  def handle_event("toggle_ad", _data, socket) do
    {:noreply, assign(socket, :toggle_ad, !socket.assigns.toggle_ad)}
  end

  def handle_event("publish_ad", data, socket) do
    IO.inspect(data, label: "intent to create")
    intent = input_to_atoms(data)

    {:ok, new_intent} = GraphQL.create_intent(%{intent: intent}, %{context: %{current_user: socket.assigns.current_user}} )
    IO.inspect(new_intent)
    {:noreply,
         socket
         |> put_flash(:info, "intent created !")}
  end


end
