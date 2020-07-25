defmodule MoodleNetWeb.My.WriteLive do
  use MoodleNetWeb, :live_view

  import MoodleNetWeb.Helpers.Common

  # alias MoodleNetWeb.Helpers.{Profiles, Account}
  # alias MoodleNetWeb.Component.HeaderLive

  def mount(params, session, socket) do
    socket = init_assigns(params, session, socket)

    {:ok,
     socket
     |> assign(
       title_placeholder: "An optional title...",
       content_placeholder: "Write a story or get a discussion started!",
       post_label: "Publish"
       #  current_user: Account.current_user_or(nil, session, %{icon: true, actor: true}),
     )}
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
end
