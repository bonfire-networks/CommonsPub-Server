defmodule MoodleNetWeb.My.WriteWidgetLive do
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

  def handle_event("toggle_post", _data, socket) do
    IO.inspect(socket.assigns.toggle_post)

    {:noreply,
     socket
     |> assign(:toggle_post, !socket.assigns.toggle_post)}
  end

  def handle_event("post", %{"content" => content, "context_id" => context_id} = data, socket) do
    if(is_nil(content) or is_nil(socket.assigns.current_user)) do
      {:noreply,
       socket
       |> put_flash(:error, "Please write something...")}
    else
      # MoodleNetWeb.Plugs.Auth.login(socket, session.current_user, session.token)
      comment = input_to_atoms(data)

      IO.inspect(context_id, label: "context_id CHOOSEN")

      if strlen(context_id) < 1 do
        {:ok, thread} =
          MoodleNetWeb.GraphQL.ThreadsResolver.create_thread(
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
          MoodleNetWeb.GraphQL.ThreadsResolver.create_thread(
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
end
