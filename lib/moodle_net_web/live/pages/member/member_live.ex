defmodule MoodleNetWeb.MemberLive do
  use MoodleNetWeb, :live_view

  import MoodleNetWeb.Helpers.Common
  alias MoodleNetWeb.Helpers.{Profiles}

  alias MoodleNetWeb.MemberLive.{
    MemberDiscussionsLive,
    MemberNavigationLive,
    MemberActivitiesLive
  }

  alias MoodleNetWeb.Component.{
    HeaderLive,
    HeroProfileLive,
    AboutLive,
    TabNotFoundLive
  }

  alias MoodleNet.{
    Repo,
    Meta.Pointers
  }

  # FIXME
  # def mount(%{auth_token: auth_token}, socket) do
  #   IO.inspect(live_mount_user: auth_token)
  #   {:ok, assign_new(socket, :auth_token, fn -> auth_token end)}
  # end

  def mount(params, session, socket) do
    socket = init_assigns(params, session, socket)

    {:ok,
     socket
     |> assign(
       page_title: "User",
       me: false,
       selected_tab: "about",
       current_user: socket.assigns.current_user
     )}
  end

  def handle_params(%{"tab" => tab} = params, _url, socket) do
    user = user_load(socket, params)

    {:noreply,
     assign(socket,
       selected_tab: tab,
       user: user,
       current_user: socket.assigns.current_user
     )}
  end

  def handle_params(%{} = params, url, socket) do
    logged_url = url =~ "my/profile"

    user = user_load(socket, params)

    {:noreply,
     assign(socket,
       me: logged_url,
       user: user,
       current_user: socket.assigns.current_user
     )}
  end

  def user_load(socket, params) do
    user = Profiles.user_load(socket, params, %{image: true, icon: true, actor: true}, 150)
    # IO.inspect(user, label: "USER")
    user
  end
end
