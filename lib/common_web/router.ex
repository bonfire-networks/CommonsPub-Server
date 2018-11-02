defmodule Pleroma.Web.Router do
  use Pleroma.Web, :router

  alias Pleroma.{Repo, User, Web.Router}

  @instance Application.get_env(:pleroma, :instance)
  @federating Keyword.get(@instance, :federating)
  @allow_relay Keyword.get(@instance, :allow_relay)
  @public Keyword.get(@instance, :public)
  @registrations_open Keyword.get(@instance, :registrations_open)

  pipeline :api do
    plug(:accepts, ["json"])
    plug(:fetch_session)
    plug(Pleroma.Plugs.OAuthPlug)
    plug(Pleroma.Plugs.BasicAuthDecoderPlug)
    plug(Pleroma.Plugs.UserFetcherPlug)
    plug(Pleroma.Plugs.SessionAuthenticationPlug)
    plug(Pleroma.Plugs.LegacyAuthenticationPlug)
    plug(Pleroma.Plugs.AuthenticationPlug)
    plug(Pleroma.Plugs.UserEnabledPlug)
    plug(Pleroma.Plugs.SetUserSessionIdPlug)
    plug(Pleroma.Plugs.EnsureUserKeyPlug)
  end

  pipeline :authenticated_api do
    plug(:accepts, ["json"])
    plug(:fetch_session)
    plug(Pleroma.Plugs.OAuthPlug)
    plug(Pleroma.Plugs.BasicAuthDecoderPlug)
    plug(Pleroma.Plugs.UserFetcherPlug)
    plug(Pleroma.Plugs.SessionAuthenticationPlug)
    plug(Pleroma.Plugs.LegacyAuthenticationPlug)
    plug(Pleroma.Plugs.AuthenticationPlug)
    plug(Pleroma.Plugs.UserEnabledPlug)
    plug(Pleroma.Plugs.SetUserSessionIdPlug)
    plug(Pleroma.Plugs.EnsureAuthenticatedPlug)
  end

  pipeline :mastodon_html do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(Pleroma.Plugs.OAuthPlug)
    plug(Pleroma.Plugs.BasicAuthDecoderPlug)
    plug(Pleroma.Plugs.UserFetcherPlug)
    plug(Pleroma.Plugs.SessionAuthenticationPlug)
    plug(Pleroma.Plugs.LegacyAuthenticationPlug)
    plug(Pleroma.Plugs.AuthenticationPlug)
    plug(Pleroma.Plugs.UserEnabledPlug)
    plug(Pleroma.Plugs.SetUserSessionIdPlug)
    plug(Pleroma.Plugs.EnsureUserKeyPlug)
  end

  pipeline :pleroma_html do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(Pleroma.Plugs.OAuthPlug)
    plug(Pleroma.Plugs.BasicAuthDecoderPlug)
    plug(Pleroma.Plugs.UserFetcherPlug)
    plug(Pleroma.Plugs.SessionAuthenticationPlug)
    plug(Pleroma.Plugs.AuthenticationPlug)
    plug(Pleroma.Plugs.EnsureUserKeyPlug)
  end

  pipeline :config do
    plug(:accepts, ["json", "xml"])
  end

  pipeline :oauth do
    plug(:accepts, ["html", "json"])
  end

  pipeline :pleroma_api do
    plug(:accepts, ["html", "json"])
  end

  scope "/oauth", Pleroma.Web.OAuth do
    get("/authorize", OAuthController, :authorize)
    post("/authorize", OAuthController, :create_authorization)
    post("/token", OAuthController, :token_exchange)
    post("/revoke", OAuthController, :token_revoke)
  end

  scope "/api", Pleroma.Web do
    pipe_through(:config)

  end

  pipeline :ap_relay do
    plug(:accepts, ["activity+json"])
  end

  pipeline :activitypub do
    plug(:accepts, ["activity+json"])
    plug(Pleroma.Web.Plugs.HTTPSignaturePlug)
  end

  scope "/", Pleroma.Web.ActivityPub do
    pipe_through(:ap_relay)

    get("/objects/:uuid", ActivityPubController, :object)
    get("/users/:nickname", ActivityPubController, :user)
    get("/users/:nickname/followers", ActivityPubController, :followers)
    get("/users/:nickname/following", ActivityPubController, :following)
    get("/users/:nickname/outbox", ActivityPubController, :outbox)
  end

  if @federating do
    if @allow_relay do
      scope "/relay", Pleroma.Web.ActivityPub do
        pipe_through(:ap_relay)
        get("/", ActivityPubController, :relay)
      end
    end

    scope "/", Pleroma.Web.ActivityPub do
      pipe_through(:activitypub)
      post("/users/:nickname/inbox", ActivityPubController, :inbox)
      post("/inbox", ActivityPubController, :inbox)
    end
  end

  pipeline :remote_media do
    plug(:accepts, ["html"])
  end

  scope "/proxy/", Pleroma.Web.MediaProxy do
    pipe_through(:remote_media)
    get("/:sig/:url", MediaProxyController, :remote)
  end
end
