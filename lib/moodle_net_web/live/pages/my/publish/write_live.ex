defmodule MoodleNetWeb.My.Publish.WriteLive do
  use MoodleNetWeb, :live_view

  import MoodleNetWeb.Helpers.Common

  alias MoodleNetWeb.Component.HeaderLive

  def mount(_params, session, socket) do
    {:ok, session_token} = MoodleNet.Access.fetch_token_and_user(session["auth_token"])
    user = e(session_token, :user, %{})

    {:ok,
     socket
     |> assign(
       title_placeholder: "An optional title for your story or discussion",
       summary_placeholder: "Write a story or get a discussion started!",
       post_label: "Post",
       current_user: user
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

  def render(assigns) do
    ~L"""
    <div class="page">
      <%= live_component(
          @socket,
          HeaderLive
        )
      %>
      <section class="page__wrapper">
        <div class="page__mainContent">
          <form action="#" phx-submit="post" class="mainContent_write">

              <input name="name" placeholder="<%= @title_placeholder %>" />
              <textarea name="content" placeholder="<%= @summary_placeholder %>"></textarea>
              <button type="submit" phx-disable-with="Posting..."><%=@post_label%></button>
            </form>
        </div>
      </section>
    </div>
    """
  end
end
