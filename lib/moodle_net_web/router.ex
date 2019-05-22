# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNetWeb.Router do
  @moduledoc """
  MoodleNet Router
  """
  use MoodleNetWeb, :router

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

  pipeline :remote_media do
    plug(:accepts, ["html"])
  end

  scope "/proxy/", MoodleNetWeb.MediaProxy do
    pipe_through(:remote_media)
    get("/:sig/:url", MediaProxyController, :remote)
  end

  @doc """
  Serve the mock homepage, or forward ActivityPub API requests to the AP module's router
  """
  scope "/" do
    get "/", MoodleNetWeb.PageController, :index

    forward "/activity_pub", ActivityPubWeb.Router
  end
end
