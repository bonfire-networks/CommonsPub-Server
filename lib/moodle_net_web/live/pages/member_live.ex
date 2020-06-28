defmodule MoodleNetWeb.MemberLive do
  use MoodleNetWeb, :live_view

  alias MoodleNetWeb.Component.HeroProfileLive
  alias MoodleNetWeb.Component.{
    HeaderLive,
    AboutLive,
    TabNotFoundLive,
  }
  alias MoodleNetWeb.GraphQL.UsersResolver
  alias MoodleNet.{
    Repo,
    Meta.Pointers
  }


  def mount(_params, _session, socket) do
    {:ok, assign(socket,
    page_title: "User",
    selected_tab: "about"
    )
  }
  end

  def handle_params(%{"username" => username}, _uri, socket) do
    id = username
    |> String.split()
    |> Enum.at(-1)
    |> String.downcase()
    {:ok, user} = UsersResolver.user(%{username: id}, nil)

    user = Repo.preload(user, :icon)
    user = Repo.preload(user, :image)
    image = Repo.preload(user.image, :content_mirror)
    icon = Repo.preload(user.icon, :content_mirror)
    # user = Repo.preload(user, :actor)

    {:noreply, assign(socket,
    user: user
      |> Map.merge(%{image: image})
      |> Map.merge(%{icon: icon}))
    }
  end

  def handle_params(%{"tab" => tab}, _url, socket) do
    {:noreply, assign(socket, selected_tab: tab)}
  end

  def handle_params(_, _url, socket) do
    {:noreply, socket}
  end


  def render(assigns) do
    ~L"""
    <div class="page">
    <%= live_component(
        @socket,
        HeaderLive,
        icon: "https://home.next.moodle.net/uploads/01E9TQEVAKAVNZCQVE94NJA7TP/moebius4.jpeg"
      )
    %>
    <section class="page__wrapper">
        <%= live_component(
          @socket,
          HeroProfileLive,
          image: @user.image.content_mirror.url,
          icon: @user.icon.content_mirror.url,
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
