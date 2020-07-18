defmodule MoodleNetWeb.LoginLive do
  use MoodleNetWeb, :live_view
  import MoodleNetWeb.Helpers.Common

  def mount(params, session, socket) do
    socket = init_assigns(params, session, socket)

    {:ok,
     socket
     |> assign(
       app_name: Application.get_env(:moodle_net, :app_name),
       app_icon: Application.get_env(:moodle_net, :app_icon, "/images/sun_face.png"),
       instance_image: "https://i.ytimg.com/vi/_qzacv8dtb4/maxresdefault.jpg",
       app_summary: MoodleNet.Instance.description()
     )}
  end

  # def handle_event("validate", %{"login" => login, "password" => password} = args, socket) do
  #   IO.inspect(args, label: "VALIDATE DATA")

  #   {:noreply, socket}
  # end

  def handle_event("login", %{"login" => login, "password" => password} = _args, socket) do
    # IO.inspect(args, label: "LOGIN DATA")

    session = MoodleNetWeb.Helpers.Account.create_session(%{login: login, password: password})
    IO.inspect(created_session: session)

    if(is_nil(session)) do
      {:noreply,
       socket
       |> put_flash(:error, "Incorrect details. Please try again...")}
    else
      # MoodleNetWeb.Plugs.Auth.login(socket, session.current_user, session.token)

      {:noreply,
       socket
       |> put_flash(:info, "Logged in!")
       |> redirect(to: "/~/?auth_token=" <> session.token)}
    end
  end
end
