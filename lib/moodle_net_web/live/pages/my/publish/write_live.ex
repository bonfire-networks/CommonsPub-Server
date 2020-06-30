defmodule MoodleNetWeb.My.Publish.WriteLive do
  use MoodleNetWeb, :live_view

  import MoodleNetWeb.Helpers.Common
  alias MoodleNetWeb.Helpers.{Profiles, Account}
  alias MoodleNetWeb.Component.HeaderLive

  def mount(_params, session, socket) do
    {:ok,
     socket
     |> assign(
       title_placeholder: "An optional title for your story or discussion",
       summary_placeholder: "Write a story or get a discussion started!",
       post_label: "Post",
       current_user: Account.current_user_or(nil, session, %{icon: true, actor: true}),
       meili_host: Application.get_env(:moodle_net, :hostname, "localhost")
     )}
  end

  def handle_event("post", %{"content" => content} = data, socket) do
    IO.inspect(data, label: "DATA")

    if(is_nil(content) or !Map.has_key?(socket.assigns, :current_user)) do
      {:noreply,
       socket
       |> put_flash(:error, "Please write something...")}
    else
      # MoodleNetWeb.Plugs.Auth.login(socket, session.current_user, session.token)

      comment = data |> Map.new(fn {k, v} -> {String.to_atom(k), v} end)

      thread =
        MoodleNet.Threads.create_with_comment(socket.assigns.current_user, %{comment: comment})

      {:noreply,
       socket
       |> put_flash(:info, "Published!")
       |> redirect(to: "/")}
    end
  end
end
