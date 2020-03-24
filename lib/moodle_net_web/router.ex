# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNetWeb.Router do
  @moduledoc """
  MoodleNet Router
  """
  use MoodleNetWeb, :router
  use Plug.ErrorHandler
  use Sentry.Plug

  if Mix.env == :dev do
    forward "/sent_emails", Bamboo.SentEmailViewerPlug
  end

  # pipeline :browser do
  #   plug :accepts, ["html"]
  #   plug :fetch_session
  #   plug :fetch_flash
  #   plug :protect_from_forgery
  #   plug :put_secure_browser_headers
  # end

  @doc """
  Serve the GraphiQL API browser on /api/graphql
  """
  pipeline :api_browser do
    # Not sure if this is ok?
    # Mixing browser and API stuff does not seem right...
    # FIXME
    plug(:accepts, ["html", "json", "css", "js", "png", "jpg", "ico"])

    plug(:fetch_session)
    plug(:fetch_flash)
    plug(MoodleNetWeb.Plugs.SetLocale)
    # plug(:protect_from_forgery)
    # plug(:put_secure_browser_headers)
    plug(MoodleNetWeb.Plugs.Auth)
  end

  pipe_through(:api_browser)

  pipeline :ensure_authenticated do
    plug(MoodleNetWeb.Plugs.EnsureAuthenticatedPlug)
  end

  @doc """
  Serve GraphQL API queries
  """
  pipeline :graphql do
    plug(MoodleNetWeb.Plugs.Auth)
    plug MoodleNetWeb.GraphQL.Context
    plug :accepts, ["json"]
  end

  scope "/api/graphql" do

    get "/schema", MoodleNetWeb.GraphQL.DevTools, :schema

    pipe_through :graphql

    forward "/", Absinthe.Plug.GraphiQL,
      schema: MoodleNetWeb.GraphQL.Schema,
      interface: :simple,
      json_codec: Jason

  end

  scope "/api/v1" do
    resources("/users", MoodleNetWeb.Accounts.UserController, only: [:create])
    resources("/sessions", MoodleNetWeb.Accounts.SessionController, only: [:create])
  end

  scope "/api/v1" do
    pipe_through(:ensure_authenticated)

    resources("/sessions", MoodleNetWeb.Accounts.SessionController,
      only: [:delete],
      singleton: true
    )
  end

  @doc """
  Serve OAuth flows
  """
  scope "/oauth", MoodleNetWeb.OAuth do
    post("/authorize", OAuthController, :create_authorization)
    post("/token", OAuthController, :token_exchange)
    post("/revoke", OAuthController, :token_revoke)

    resources("/apps", AppController, only: [:create])
  end

  pipeline :media do
    plug(:accepts, ["html"])
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  scope MoodleNet.MediaProxy.media_path(), MoodleNetWeb do
    pipe_through(:media)
    get("/:sig/:url/*rest", MediaProxyController, :remote)
  end

  pipeline :well_known do
    plug(:accepts, ["json", "jrd+json"])
  end

  scope "/.well-known", ActivityPubWeb do
    pipe_through(:well_known)

    get "/webfinger", WebFingerController, :webfinger
  end

  @doc """
  Serve the mock homepage, or forward ActivityPub API requests to the AP module's router
  """

  pipeline :activity_pub do
    plug(:accepts, ["activity+json", "json", "html"])
  end

  pipeline :signed_activity_pub do
    plug(:accepts, ["activity+json", "json"])
    plug(ActivityPubWeb.Plugs.HTTPSignaturePlug)
  end

  ap_base_path = System.get_env("AP_BASE_PATH", "/pub")

  scope ap_base_path, ActivityPubWeb do
    pipe_through(:activity_pub)

    get "/objects/:uuid", ActivityPubController, :object
    get "/actors/:username", ActivityPubController, :actor
    get "/actors/:username/followers", ActivityPubController, :followers
    get "/actors/:username/following", ActivityPubController, :following
    get "/actors/:username/outbox", ActivityPubController, :noop
  end

  scope ap_base_path, ActivityPubWeb do
    pipe_through(:signed_activity_pub)

    post "/actors/:username/inbox", ActivityPubController, :inbox
    post "/shared_inbox", ActivityPubController, :inbox
  end

  scope "/taxonomy" do
    get "/", Taxonomy.Utils, :test

  end

  scope "/" do
    get "/", MoodleNetWeb.PageController, :index
  end
end
