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
    # HeaderLive,
    HeroProfileLive,
    AboutLive,
    TabNotFoundLive
  }

  # alias MoodleNet.{
  #   Repo
  # }

  # FIXME
  # def mount(%{auth_token: auth_token}, socket) do
  #   IO.inspect(live_mount_user: auth_token)
  #   {:ok, assign_new(socket, :auth_token, fn -> auth_token end)}
  # end

  def mount(params, session, socket) do
    socket = init_assigns(params, session, socket)

    user =
      Profiles.user_load(socket, params, %{
        image: true,
        icon: true,
        actor: true,
        is_followed_by: socket.assigns.current_user
      })

    {:ok,
     socket
     |> assign(
       page_title: "User",
       me: false,
       selected_tab: "about",
       user: user,
       current_user: socket.assigns.current_user
     )}
  end

  def handle_params(%{"tab" => tab} = params, _url, socket) do
    {:noreply,
     assign(socket,
       selected_tab: tab
       #  current_user: socket.assigns.current_user
     )}
  end

  def handle_params(%{} = params, url, socket) do
    # logged_url = url =~ "my/profile"

    {:noreply,
     assign(socket,
       #  me: logged_url
       #  user: user,
       current_user: socket.assigns.current_user
     )}
  end

  def handle_event("follow", _data, socket) do
    f =
      MoodleNetWeb.GraphQL.FollowsResolver.create_follow(%{context_id: socket.assigns.user.id}, %{
        context: %{current_user: socket.assigns.current_user}
      })

     IO.inspect(f)

    # TODO: error handling

    {:noreply,
     socket
     |> put_flash(:info, "Followed!")
     |> assign(user: socket.assigns.user |> Map.merge(%{is_followed: true}))
     |> push_patch(to: "/@" <> socket.assigns.user.username)}
  end

  def handle_event("unfollow", _data, socket) do
    uf = Profiles.unfollow(socket.assigns.current_user, socket.assigns.user.id)

    IO.inspect(uf)

    # TODO: error handling

    {
      :noreply,
      socket
      |> assign(user: socket.assigns.user |> Map.merge(%{is_followed: false}))
      |> put_flash(:info, "Unfollowed...")
      |> push_patch(to: "/@" <> socket.assigns.user.username)
    }
  end
end
