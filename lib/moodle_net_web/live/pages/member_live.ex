defmodule MoodleNetWeb.MemberLive do
  use MoodleNetWeb, :live_view

  import MoodleNetWeb.Helpers.Common

  alias MoodleNetWeb.Component.HeroProfileLive

  alias MoodleNetWeb.Component.{
    HeaderLive,
    AboutLive,
    TabNotFoundLive
  }

  alias MoodleNetWeb.GraphQL.UsersResolver

  alias MoodleNet.{
    Repo,
    Meta.Pointers
  }

  alias MoodleNetWeb.Helpers.{Profiles}

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       page_title: "User",
       selected_tab: "about"
     )}
  end

  def handle_params(%{"tab" => tab}, _url, socket) do
    {:noreply, assign(socket, selected_tab: tab)}
  end

  def handle_params(%{} = params, _url, socket) do
    username =
      if(Map.has_key?(params, :username)) do
        params.username
        |> String.split()
        |> Enum.at(-1)
        |> String.downcase()
      else
        # TODO: use logged in user here
        "mayel"
      end

    {:ok, user} = UsersResolver.user(%{username: username}, nil)
    user = Profiles.prepare(user, %{image: true})

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
          image: e(@user, :icon, ""),
          icon: e(@user, :icon, ""),
          name: @user.name,
          username: @user.actor.preferred_username,
          website: @user.website,
          location: @user.location,
          email: ""
        )  %>

        <div class="mainContent__navigation home__navigation">
          Insert navigation here
        </div>

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
