defmodule MoodleNetWeb.SignupLive do
  use MoodleNetWeb, :live_view
  import MoodleNetWeb.Helpers.Common

  def mount(params, session, socket) do
    socket = init_assigns(params, session, socket)

    {:ok,
     socket
     |> assign(
       email: "",
       app_name: Application.get_env(:moodle_net, :app_name),
       app_icon: Application.get_env(:moodle_net, :app_icon, "/images/sun_face.png")
     )}
  end

  def handle_params(%{"email" => email}, _url, socket) do
    {:noreply, assign(socket, email: email)}
  end

  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  def handle_event(
        "signup",
        %{
          "email" => email,
          "preferred_username" => _username,
          "password" => password,
          "password2" => password2
        } = data,
        socket
      ) do
    # IO.inspect(data, label: "SIGNUP DATA")

    if(
      strlen(email) < 5 or strlen(password) < 6 or
        password != password2
    ) do
      {:noreply,
       socket
       |> put_flash(:error, "Please check your input and try again...")}
    else
      input = Map.drop(input_to_atoms(data), ["password2"])
      IO.inspect(input)

      case MoodleNetWeb.GraphQL.UsersResolver.create_user(%{user: input}, %{}) do
        {:ok, _user} ->
          # IO.inspect(user)

          {:noreply,
           socket
           |> put_flash(
             :info,
             "Signed up! Please check your email inbox (and spam folder) to activate your account."
           )
           |> redirect(to: "/")}

        {:error, err} ->
          IO.inspect(err)

          # TODO: display the error
          {:noreply, assign(socket, :notice, "Something went wrong...")}

        _ ->
          {:noreply, assign(socket, :notice, "Something went wrong!")}
      end
    end
  end

  def handle_event(
        "signup",
        _data,
        socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "Please answer all the fields...")}
  end
end
