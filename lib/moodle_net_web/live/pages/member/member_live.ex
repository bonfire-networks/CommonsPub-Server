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

  def mount(_params, session, socket) do
    with {:ok, session_token} <- MoodleNet.Access.fetch_token_and_user(session["auth_token"]) do
      {:ok,
       socket
       |> assign(
         page_title: "User",
         selected_tab: "about",
         me: false,
         current_user: Profiles.prepare(session_token.user, %{icon: true, actor: true})
       )}
    else
      {:error, _} ->
        {:ok,
         socket
         |> assign(
           page_title: "User",
           me: false,
           selected_tab: "about",
           current_user: nil
         )}
    end
  end

  def handle_params(%{"tab" => tab} = params, _url, socket) do
    user = Profiles.user_load(socket, params, %{image: true, icon: true, actor: true})

    {:noreply,
     assign(socket,
       selected_tab: tab,
       user: user,
       current_user: socket.assigns.current_user
     )}
  end

  def handle_params(%{} = params, url, socket) do
    user = Profiles.user_load(socket, params, %{image: true, icon: true, actor: true})
    logged_url = url =~ "my/profile"
    IO.inspect(user, label: "USER")

    {:noreply,
     assign(socket,
       me: logged_url,
       user: user,
       current_user: socket.assigns.current_user
     )}
  end
end
