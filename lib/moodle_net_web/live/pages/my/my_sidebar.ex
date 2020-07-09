defmodule MoodleNetWeb.My.MySidebar do
  use MoodleNetWeb, :live_component

  import MoodleNetWeb.Helpers.Common

  alias MoodleNetWeb.Helpers.{Profiles, Communities}

  def update(assigns, socket) do
    {
      :ok,
      socket
      |> assign(assigns)
    }
  end

  def handle_event("new_community", %{"name" => name} = data, socket) do
    IO.inspect(data, label: "DATA")

    if(is_nil(name) or !Map.has_key?(socket.assigns, :current_user)) do
      {:noreply,
       socket
       |> put_flash(:error, "Please enter a name...")}
    else
      community = data |> Map.new(fn {k, v} -> {String.to_atom(k), v} end)

      {:ok, community} =
        MoodleNetWeb.GraphQL.CommunitiesResolver.create_community(
          %{community: community},
          %{context: %{current_user: socket.assigns.current_user}}
        )

      # TODO: handle errors
      IO.inspect(community, label: "community created")

      if(!is_nil(community) and community.actor.preferred_username) do
        {:noreply,
         socket
         |> put_flash(:info, "Community created !")
         # change redirect
         |> redirect(to: "/&" <> community.actor.preferred_username)}
      else
        {:noreply,
         socket
         |> redirect(to: "/instance/communities/")}
      end
    end
  end
end
