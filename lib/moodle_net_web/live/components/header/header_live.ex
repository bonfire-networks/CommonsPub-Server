defmodule MoodleNetWeb.Component.HeaderLive do
  use Phoenix.LiveComponent

  import MoodleNetWeb.Helpers.Common

  alias MoodleNetWeb.GraphQL.{
    UsersResolver
  }

  alias MoodleNetWeb.Helpers.{Profiles}

  def mount(socket) do
    {:ok,
     socket
     |> assign(
       app_name: Application.get_env(:moodle_net, :app_name),
       app_icon: Application.get_env(:moodle_net, :app_icon, "/images/sun_face.png")
     )}
  end

  def update(assigns, socket) do
    # IO.inspect(assigns)
    # TODO: use logged in user here
    username = "mayel"
    user = Profiles.user_get(username, %{icon: true, actor: true})
    {:ok, assign(socket, user: user)}
  end

  def render(assigns) do
    ~L"""
      <header class="page__header">
      <div class="header__left">
        <a href="/">
          <img src="<%=@app_icon%>" alt="<%=@app_name%>" />
        </a>
        <a class="button" href="/my/timeline">My Timeline</a>
        <input placeholder="Search..." />
      </div>
      <div class="header__right">
        <a class="button" href="/write"><i class="feather-file-text"></i> New story</a>
        <div class="header__avatar">
          <a href="/@<%= e(@user, :actor, :preferred_username, "") %>"><img src="<%=e(@user, :icon_url, "") %>" /></a>
        </div>
      </div>
      </header>
    """
  end
end
