defmodule CommonsPub.Web.My.MyHeader do
  use CommonsPub.Web, :live_component

  import CommonsPub.Web.Helpers.Common

  # alias CommonsPub.Web.Helpers.{Profiles, Communities}

  def update(assigns, socket) do
    {
      :ok,
      socket
      |> assign(assigns)
    }
  end

  def handle_params(%{"signout" => _name} = _data, _socket) do
    IO.inspect("signout!")
  end

  def handle_event("toggle_post", _data, socket) do
    IO.inspect(socket.assigns.toggle_post)

    {:noreply,
     socket
     |> assign(:toggle_post, !socket.assigns.toggle_post)}
  end

  def handle_event("toggle_community", _data, socket) do
    {:noreply, assign(socket, :toggle_community, !socket.assigns.toggle_community)}
  end

  def handle_event("toggle_collection", _data, socket) do
    {:noreply, assign(socket, :toggle_collection, !socket.assigns.toggle_collection)}
  end

  def handle_event("toggle_link", _data, socket) do
    {:noreply, assign(socket, :toggle_link, !socket.assigns.toggle_link)}
  end

  def handle_event("toggle_ad", _data, socket) do
    {:noreply, assign(socket, :toggle_ad, !socket.assigns.toggle_ad)}
  end

  def handle_event("post", %{"content" => content, "context_id" => context_id} = data, socket) do
    if(is_nil(content) or is_nil(socket.assigns.current_user)) do
      {:noreply,
       socket
       |> put_flash(:error, "Please write something...")}
    else
      # CommonsPub.Web.Plugs.Auth.login(socket, session.current_user, session.token)
      comment = input_to_atoms(data)

      IO.inspect(context_id, label: "context_id CHOOSEN")

      if strlen(context_id) < 1 do
        {:ok, thread} =
          CommonsPub.Web.GraphQL.ThreadsResolver.create_thread(
            %{comment: comment},
            %{context: %{current_user: socket.assigns.current_user}}
          )

        {:noreply,
         socket
         |> put_flash(:info, "Published!")
         # change redirect
         |> push_redirect(to: "/!" <> thread.thread_id)}
      else
        {:ok, thread} =
          CommonsPub.Web.GraphQL.ThreadsResolver.create_thread(
            %{context_id: context_id, comment: comment},
            %{context: %{current_user: socket.assigns.current_user}}
          )

        {:noreply,
         socket
         |> put_flash(:info, "Published!")
         # change redirect
         |> push_redirect(to: "/!" <> thread.thread_id)}
      end
    end
  end

  def handle_event("new_community", %{"name" => name} = data, socket) do
    if(is_nil(name) or !Map.has_key?(socket.assigns, :current_user)) do
      {:noreply,
       socket
       |> put_flash(:error, "Please enter a name...")}
    else
      community = input_to_atoms(data)

      {:ok, community} =
        CommonsPub.Web.GraphQL.CommunitiesResolver.create_community(
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
         |> push_redirect(to: "/&" <> community.actor.preferred_username)}
      else
        {:noreply,
         socket
         |> push_redirect(to: "/instance/communities/")}
      end
    end
  end
end
