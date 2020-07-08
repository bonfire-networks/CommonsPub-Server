defmodule MoodleNetWeb.CommunityLive do
  use MoodleNetWeb, :live_view

  import MoodleNetWeb.Helpers.Common
  alias MoodleNetWeb.Helpers.{Communities}
  alias MoodleNetWeb.GraphQL.CommunitiesResolver

  alias MoodleNetWeb.CommunityLive.{
    CommunityDiscussionsLive,
    CommunityMembersLive,
    # CommunityNavigationLive,
    CommunityActivitiesLive
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
       page_title: "Community",
       selected_tab: "about",
       current_user: socket.assigns.current_user
     )}
  end

  def handle_params(%{"tab" => tab} = params, _url, socket) do
    community = Communities.community_load(socket, params, %{image: true, actor: true})
    IO.inspect(community, label: "COMMUNITY")

    {:noreply,
     assign(socket,
       selected_tab: tab,
       community: community,
       current_user: socket.assigns.current_user
     )}
  end

  def handle_params(%{} = params, url, socket) do
    community = Communities.community_load(socket, params, %{image: true, actor: true})

    # IO.inspect(community, label: "community")

    {:noreply,
     assign(socket,
       community: community,
       current_user: socket.assigns.current_user
     )}
  end

  defp link_body(name, icon) do
    assigns = %{name: name, icon: icon}

    ~L"""
      <i class="<%= @icon %>"></i>
      <%= @name %>
    """
  end
end
