defmodule MoodleNetWeb.CommunityLive do
  use MoodleNetWeb, :live_view

  import MoodleNetWeb.Helpers.Common
  alias MoodleNetWeb.Helpers.{Communities, Profiles}
  # alias MoodleNetWeb.GraphQL.CommunitiesResolver
  alias MoodleNetWeb.CommunityLive.{
    CommunityDiscussionsLive,
    CommunityMembersLive,
    CommunityMembersPreviewLive,
    # CommunityNavigationLive,
    CommunityCollectionsLive,
    # CommunityWriteLive,
    CommunityActivitiesLive
  }

  alias MoodleNetWeb.Component.{
    # HeaderLive,
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

    {:ok,
     socket
     |> assign(
       page_title: "Community",
       selected_tab: "about",
       current_user: socket.assigns.current_user
     )}
  end

  def handle_params(%{"tab" => tab} = params, _url, socket) do
    community =
      Communities.community_load(socket, params, %{
        icon: true,
        image: true,
        actor: true,
        is_followed_by: socket.assigns.current_user
      })

    {:noreply,
     assign(socket,
       selected_tab: tab,
       community: community,
       current_context: community,
       current_user: socket.assigns.current_user
     )}
  end

  def handle_params(%{} = params, _url, socket) do
    community =
      Communities.community_load(socket, params, %{
        icon: true,
        image: true,
        actor: true,
        is_followed_by: socket.assigns.current_user
      })

    # IO.inspect(community, label: "community")

    {:noreply,
     assign(socket,
       community: community,
       current_context: community,
       current_user: socket.assigns.current_user
     )}
  end

  def handle_event("flag", %{"message" => message} = _args, socket) do
    {:ok, flag} =
      MoodleNetWeb.GraphQL.FlagsResolver.create_flag(
        %{context_id: socket.assigns.community.id, message: message},
        %{
          context: %{current_user: socket.assigns.current_user}
        }
      )

    IO.inspect(flag, label: "FLAG")

    # IO.inspect(f)
    # TODO: error handling

    {
      :noreply,
      socket
      |> put_flash(:info, "Your flag will be revied by an admin!")
      #  |> push_patch(to: "/&" <> socket.assigns.community.username)
    }
  end

  def handle_event("follow", _data, socket) do
    _f =
      MoodleNetWeb.GraphQL.FollowsResolver.create_follow(
        %{context_id: socket.assigns.community.id},
        %{
          context: %{current_user: socket.assigns.current_user}
        }
      )

    # IO.inspect(f)
    # TODO: error handling

    {
      :noreply,
      socket
      |> put_flash(:info, "Joined!")
      |> assign(community: socket.assigns.community |> Map.merge(%{is_followed: true}))
      #  |> push_patch(to: "/&" <> socket.assigns.community.username)
    }
  end

  def handle_event("unfollow", _data, socket) do
    _uf = Profiles.unfollow(socket.assigns.current_user, socket.assigns.community.id)

    # IO.inspect(uf)
    # TODO: error handling

    {
      :noreply,
      socket
      |> assign(community: socket.assigns.community |> Map.merge(%{is_followed: false}))
      |> put_flash(:info, "Left...")
      # |> push_patch(to: "/&" <> socket.assigns.community.username)
    }
  end

  def handle_event("edit_community", %{"name" => name} = data, socket) do
    # IO.inspect(data, label: "DATA")

    if(is_nil(name) or !Map.has_key?(socket.assigns, :current_user)) do
      {:noreply,
       socket
       |> put_flash(:error, "Please enter a name...")}
    else
      changes = input_to_atoms(data)

      {:ok, community} =
        MoodleNetWeb.GraphQL.CommunitiesResolver.update_community(
          %{community: changes, community_id: socket.assigns.community.id},
          %{
            context: %{current_user: socket.assigns.current_user}
          }
        )

      # TODO: handle errors
      # IO.inspect(community, label: "community updated")

      if(community) do
        community =
          Profiles.prepare(community, %{
            icon: true,
            image: true,
            actor: true,
            is_followed_by: socket.assigns.current_user
          })

        {
          :noreply,
          socket
          |> assign(community: community)
          |> put_flash(:info, "Community updated !")
          # change redirect
        }
      else
        {
          :noreply,
          socket
          #  |> push_patch(to: "/&" <> socket.assigns.community.username)
        }
      end
    end
  end

  @doc """
  Forward PubSub activities in timeline to our timeline component
  """
  def handle_info({:pub_feed_activity, activity}, socket),
    do:
      MoodleNetWeb.Helpers.Activites.pubsub_activity_forward(
        activity,
        CommunityActivitiesLive,
        :community_timeline,
        socket
      )

  defp link_body(name, icon) do
    assigns = %{name: name, icon: icon}

    ~L"""
      <i class="<%= @icon %>"></i>
      <%= @name %>
    """
  end
end
