defmodule CommonsPub.Web.MemberLive do
  use CommonsPub.Web, :live_view

  import CommonsPub.Utils.Web.CommonHelper
  alias CommonsPub.Profiles.Web.ProfilesHelper

  alias CommonsPub.Web.MemberLive.{
    MemberDiscussionsLive,
    HeroProfileLive,
    MemberNavigationLive,
    MemberActivitiesLive,
    # MemberAdsLive,
    MemberCommunitiesLive,
    MemberFollowingLive,
    MemberLikesLive
  }

  alias CommonsPub.Web.Component.{
    # HeaderLive,
    AboutLive
    # TabNotFoundLive
  }

  # alias CommonsPub.{
  #   Repo
  # }

  # FIXME
  # def mount(%{auth_token: auth_token}, socket) do
  #   IO.inspect(live_mount_user: auth_token)
  #   {:ok, assign_new(socket, :auth_token, fn -> auth_token end)}
  # end

  def mount(params, session, socket) do
    socket = init_assigns(params, session, socket)
    # IO.inspect(socket.endpoint)
    user =
      ProfilesHelper.user_load(socket, params, %{
        image: true,
        icon: true,
        character: true,
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

  def handle_params(%{"tab" => tab} = _params, _url, socket) do
    {:noreply,
     assign(socket,
       selected_tab: tab
       #  current_user: socket.assigns.current_user
     )}
  end

  def handle_params(%{} = _params, _url, socket) do
    # logged_url = url =~ "my/profile"

    {:noreply,
     assign(socket,
       #  me: logged_url
       #  user: user,
       current_user: socket.assigns.current_user
     )}
  end

  def handle_event("follow", _data, socket) do
    _f =
      CommonsPub.Web.GraphQL.FollowsResolver.create_follow(
        %{context_id: socket.assigns.user.id},
        %{
          context: %{current_user: socket.assigns.current_user}
        }
      )

    #  IO.inspect(f)

    # TODO: error handling

    {:noreply,
     socket
     |> put_flash(:info, "Followed!")
     |> assign(user: socket.assigns.user |> Map.merge(%{is_followed: true}))
     |> push_patch(to: "/@" <> socket.assigns.user.username)}
  end

  def handle_event("unfollow", _data, socket) do
    _uf = ProfilesHelper.unfollow(socket.assigns.current_user, socket.assigns.user.id)

    # IO.inspect(uf)

    # TODO: error handling

    {
      :noreply,
      socket
      |> assign(user: socket.assigns.user |> Map.merge(%{is_followed: false}))
      |> put_flash(:info, "Unfollowed...")
      |> push_patch(to: "/@" <> socket.assigns.user.username)
    }
  end

  @doc """
  Forward PubSub activities in timeline to our timeline component
  """
  def handle_info({:pub_feed_activity, activity}, socket),
    do:
      CommonsPub.Activities.Web.ActivitiesHelper.pubsub_activity_forward(
        activity,
        CommonsPub.Web.MemberLive.MemberActivitiesLive,
        :member_timeline,
        socket
      )
end
