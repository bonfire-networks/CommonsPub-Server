defmodule MoodleNetWeb.MemberLive do
  use MoodleNetWeb, :live_view

  import MoodleNetWeb.Helpers.Common
  alias MoodleNetWeb.Helpers.{Profiles}
  alias MoodleNetWeb.MemberLive.MemberActivitiesLive

  alias MoodleNetWeb.Component.{
    HeaderLive,
    HeroProfileLive,
    AboutLive,
    TabNotFoundLive,
    NavigationProfileLive
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

  def render(assigns) do
    ~L"""
    <div class="page">
    <%= live_component(
        @socket,
        HeaderLive
        )
    %>
    <section class="page__wrapper">
        <%= live_component(
          @socket,
          HeroProfileLive,
          user: @user
        )  %>

        <%= live_component(
          @socket,
          NavigationProfileLive,
          selected: @selected_tab,
          username: e(@user, :actor, :preferred_username, "")
        )
      %>

      <div class="mainContent__selected">
        <%= cond do %>
        <% @selected_tab == "about" ->  %>
          <div class="selected__header">
            <h3><%= @selected_tab %></h3>
          </div>
          <div class="selected__area">
            <%= live_component(
                @socket,
                AboutLive,
                description: @user.summary
              )
            %>


          </div>

          <% @selected_tab == "timeline" ->  %>
          <div class="selected__header">
            <h3><%= @selected_tab %></h3>
          </div>
          <div class="selected__area">

            <%= live_component(
              @socket,
              MemberActivitiesLive,
              user: @user,
              selected_tab: @selected_tab,
              id: :timeline,
              # page: 1,
              # has_next_page: false,
              # after: [],
              # before: [],
              # activities: []
            ) %>
          </div>



          <% true -> %>
          <%= live_component(
              @socket,
              TabNotFoundLive
          ) %>
        <% end %>

          </div>
        </div>
      </div>

    </section>
    </div>

    """
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
