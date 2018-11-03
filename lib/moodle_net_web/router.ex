defmodule MoodleNetWeb.Router do
  use MoodleNetWeb, :router

  alias MoodleNet.{Repo, User, Web.Router}

  @instance Application.get_env(:moodle_net, :instance)

  pipeline :api do
    plug(:accepts, ["json"])
    plug(:fetch_session)
    plug(MoodleNet.Plugs.OAuthPlug)
    plug(MoodleNet.Plugs.AuthenticationPlug)
    plug(MoodleNet.Plugs.UserEnabledPlug)
    plug(MoodleNet.Plugs.EnsureUserKeyPlug)
    # plug(MoodleNet.Plugs.EnsureAuthenticatedPlug)
  end

  pipeline :oauth do
    plug(:accepts, ["html", "json"])
  end

  scope "/oauth", MoodleNetWeb.OAuth do
    get("/authorize", OAuthController, :authorize)
    post("/authorize", OAuthController, :create_authorization)
    post("/token", OAuthController, :token_exchange)
    post("/revoke", OAuthController, :token_revoke)
  end

  pipeline :remote_media do
    plug(:accepts, ["html"])
  end

  scope "/proxy/", MoodleNetWeb.MediaProxy do
    pipe_through(:remote_media)
    get("/:sig/:url", MediaProxyController, :remote)
  end

  forward "/", ActivityPubWeb.Router
end
