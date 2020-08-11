defmodule MoodleNetWeb.CreateNewPasswordLive do
  use MoodleNetWeb, :live_view
  import MoodleNetWeb.Helpers.Common

  def mount(%{"token" => token} = params, session, socket) do
    socket = init_assigns(params, session, socket)

    {:ok,
     socket
     |> assign(
       app_name: Application.get_env(:moodle_net, :app_name),
       token: token
     )}
  end

  def handle_event("create-password", %{"new-password" => pwd, "confirm-new-password" => confirm_pwd} = _data, socket) do
    IO.inspect(socket.assigns.token)
    if (pwd == confirm_pwd) do
      reset = MoodleNetWeb.GraphQL.UsersResolver.reset_password(%{token: socket.assigns.token, password: pwd}, %{})
      IO.inspect(reset)
      if {:ok, msg} = reset  do
        {:noreply, socket
          |> put_flash(:success, "You have successfully updated your password!")
          |> redirect(to: "/~/login")}
      else
        {:noreply, socket
          |> put_flash(:error, "Something got wrong!")
          |> redirect(to: "/~/login")}
      end
      else
        {:noreply, socket
          |> put_flash(:error, "Passwords have to match!")}
      end
  end
end
