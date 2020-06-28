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
    # IO.inspect(live_mount_params: _params)
    # IO.inspect(live_mount_session: session)

    {:ok, session_token} = MoodleNet.Access.fetch_token_and_user(session["auth_token"])

    # IO.inspect(session_token_user: session_token.user)

    {:ok,
     assign(socket,
       page_title: "User",
       selected_tab: "about",
       current_user: session_token.user
     )}
  end

  def handle_params(%{"tab" => tab} = params, _url, socket) do
    user = Profiles.user_load(socket, params, %{image: true, icon: true, actor: true})

    {:noreply,
     assign(socket,
       selected_tab: tab,
       user: user
     )}
  end

  def handle_params(%{} = params, _url, socket) do
    user = Profiles.user_load(socket, params, %{image: true, icon: true, actor: true})

    {:noreply,
     assign(socket,
       user: user
     )}
  end

  defp link_body(name, icon) do
    assigns = %{name: name, icon: icon}

    ~L"""
      <i class="<%= @icon %>"></i>
      <%= @name %>
    """
  end

  def handle_event("test", params, socket) do
    {:noreply, put_flash(socket, :info, "It worked!")}
  end
end
