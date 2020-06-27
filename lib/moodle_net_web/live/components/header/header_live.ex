defmodule MoodleNetWeb.Component.HeaderLive do
  use Phoenix.LiveComponent

  import MoodleNetWeb.Helpers.Common

  alias MoodleNetWeb.GraphQL.{
    UsersResolver
  }

  alias MoodleNetWeb.Helpers.{Profiles}

  def update(assigns, socket) do
    # IO.inspect(assigns)
    # TODO: use logged in user here
    username = "mayel"
    {:ok, user} = UsersResolver.user(%{username: username}, nil)
    user = Profiles.prepare(user)
    {:ok, assign(socket, user: user)}
  end

  def render(assigns) do
    ~L"""
      <header class="page__header">
      <div class="header__left">
        <a href="/">
          <img src="/images/sun_face.png" alt="logo" />
        </a>
        <input placeholder="Search..." />
      </div>
      <div class="header__right">
        <a class="button button-clear right__discover" href="/my/timeline">My Timeline</a>
        <a class="button" href="/write"><i class="feather-file-text"></i> New story</a>
        <div class="header__avatar">
          <a href="/@<%= e(@user, :actor, :preferred_username, "") %>"><img src="<%=e(@user, :icon, "") %>" /></a>
        </div>
      </div>
      </header>
    """
  end
end
