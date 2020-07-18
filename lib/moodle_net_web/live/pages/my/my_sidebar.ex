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

  def handle_event("post", %{"content" => content} = data, socket) do
    IO.inspect(data, label: "POST DATA")

    if(is_nil(content) or is_nil(socket.assigns.current_user)) do
      {:noreply,
       socket
       |> put_flash(:error, "Please write something...")}
    else
      # MoodleNetWeb.Plugs.Auth.login(socket, session.current_user, session.token)

      comment = input_to_atoms(data)

      {:ok, thread} =
        MoodleNetWeb.GraphQL.ThreadsResolver.create_thread(
          %{comment: comment},
          %{context: %{current_user: socket.assigns.current_user}}
        )

      IO.inspect(thread, label: "THREAD")

      {:noreply,
       socket
       |> put_flash(:info, "Published!")
       # change redirect
       |> push_redirect(to: "/!" <> thread.thread_id)}
    end
  end

  def handle_event("title", _data, socket) do
    IO.inspect("test")
    {
      :noreply,
      socket
      |> assign(
        show_title: !socket.assigns.show_title
      )
    }
  end

  def handle_event("communities", _data ,socket) do
    {
      :noreply,
      socket
      |> assign(
        show_communities: !socket.assigns.show_communities
      )
    }
  end

  def handle_event("new_community", %{"name" => name} = data, socket) do
    if(is_nil(name) or !Map.has_key?(socket.assigns, :current_user)) do
      {:noreply,
       socket
       |> put_flash(:error, "Please enter a name...")}
    else
      community = input_to_atoms(data)

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
         |> push_redirect(to: "/&" <> community.actor.preferred_username)}
      else
        {:noreply,
         socket
         |> push_redirect(to: "/instance/communities/")}
      end
    end
  end
end
