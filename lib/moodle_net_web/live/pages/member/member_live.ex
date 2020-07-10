defmodule MoodleNetWeb.MemberLive do
  use MoodleNetWeb, :live_view

  import MoodleNetWeb.Helpers.Common
  alias MoodleNetWeb.Helpers.{Profiles}

  alias MoodleNetWeb.MemberLive.{
    MemberDiscussionsLive,
    MemberNavigationLive,
    MemberActivitiesLive,
    MemberCommunitiesLive,
    MemberFollowingLive
  }

  alias MoodleNetWeb.Component.{
    HeaderLive,
    HeroProfileLive,
    AboutLive,
    TabNotFoundLive
  }

  alias MoodleNet.{
    Repo
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
    user = Profiles.user_load(socket, params)

    {:noreply,
     assign(socket,
       selected_tab: tab,
       user: user,
       current_user: socket.assigns.current_user
     )}
  end

  def handle_params(%{} = params, url, socket) do
    logged_url = url =~ "my/profile"

    user = Profiles.user_load(socket, params)

    {:noreply,
     assign(socket,
       me: logged_url,
       user: user,
       current_user: socket.assigns.current_user
     )}
  end

  def handle_event("follow", data, socket) do
    f =
      MoodleNetWeb.GraphQL.FollowsResolver.create_follow(%{context_id: socket.assigns.user.id}, %{
        context: %{current_user: socket.assigns.current_user}
      })

    IO.inspect(f)

    # TODO: error handling

    {:noreply,
     socket
     |> put_flash(:info, "Followed!")
     # change redirect
     |> redirect(to: "/@" <> socket.assigns.user.username)}
  end
end
