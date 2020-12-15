defmodule CommonsPub.Web.My.WriteModalLive do
  use CommonsPub.Web, :live_component



  # def update(assigns, socket) do
  #   {
  #     :ok,
  #     socket
  #     |> assign(assigns)
  #   }
  # end

  def handle_event("toggle_post", _data, socket) do
    IO.inspect(socket.assigns.toggle_post)

    {:noreply,
     socket
     |> assign(:toggle_post, !socket.assigns.toggle_post)}
  end

  def handle_event("toggle_title", _data, socket) do
    IO.inspect("test")

    {
      :noreply,
      socket
      |> assign(show_title: !socket.assigns.show_title)
    }
  end

  def handle_event("toggle_fullmodal", _data, socket) do
    IO.inspect("test")

    {
      :noreply,
      socket
      |> assign(toggle_fullmodal: !socket.assigns.toggle_fullmodal)
    }
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

      with {:ok, thread} <-
             CommonsPub.Web.GraphQL.ThreadsResolver.create_thread(
               %{context_id: context_id, comment: comment},
               %{context: %{current_user: socket.assigns.current_user}}
             ) do
        {:noreply,
         socket
         |> put_flash(:info, "Published!")
         # change redirect
         |> push_redirect(to: "/!" <> thread.thread_id)}
      else
        _e ->
          {:noreply,
           socket
           |> put_flash(:info, "Error, could not publish :(")}
      end
    end
  end
end
