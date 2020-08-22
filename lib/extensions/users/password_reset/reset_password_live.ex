defmodule MoodleNetWeb.ResetPasswordLive do
  use MoodleNetWeb, :live_view
  import MoodleNetWeb.Helpers.Common

  def mount(params, session, socket) do
    socket = init_assigns(params, session, socket)

    {:ok,
     socket
     |> assign(
       app_name: Application.get_env(:moodle_net, :app_name),
     )}
  end

  def handle_event("reset", %{"email" => mail} = _data, socket) do
    reset = MoodleNetWeb.GraphQL.UsersResolver.reset_password_request(%{email: mail}, %{})
    IO.inspect(reset, label: "reset")
    {:noreply,
    socket
    |> put_flash(:info, "If your email is linked to an account in our database, we have sent you an email with which you can reset your password. It may take a few minutes to arrive depending on your mail provider!")
    |> redirect(to: "/~/login")}

  end
end
