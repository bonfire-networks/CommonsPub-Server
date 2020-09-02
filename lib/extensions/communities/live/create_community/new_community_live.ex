defmodule CommonsPub.Web.My.NewCommunityLive do
  use CommonsPub.Web, :live_component

  import CommonsPub.Utils.Web.CommonHelper

  def update(assigns, socket) do
    {
      :ok,
      socket
      |> assign(assigns)
    }
  end

  def handle_event("toggle_community", _data, socket) do
    {:noreply, assign(socket, :toggle_community, !socket.assigns.toggle_community)}
  end

  def handle_event("new_community", %{"name" => name, "context_id" => context_id} = data, socket) do
    if(is_nil(name) or !Map.has_key?(socket.assigns, :current_user)) do
      {:noreply,
       socket
       |> put_flash(:error, "Please enter a name...")}
    else
      community = input_to_atoms(data)

      {:ok, community} =
        CommonsPub.Web.GraphQL.CommunitiesResolver.create_community(
          %{community: community, context_id: context_id},
          %{context: %{current_user: socket.assigns.current_user}}
        )

      # TODO: handle errors
      IO.inspect(community, label: "community created")

      if(!is_nil(community) and community.actor.preferred_username) do
        {:noreply,
         socket
         |> put_flash(:info, "Community created !")
         # change redirect
         |> push_redirect(to: "/&" <> community.actor.preferred_username)}
      else
        {:noreply,
         socket
         |> push_redirect(to: "/instance/communities/")}
      end
    end
  end
end
