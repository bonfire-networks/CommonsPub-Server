defmodule MoodleNetWeb.Router do
  use MoodleNetWeb, :router

  # pipeline :browser do
  #   plug :accepts, ["html"]
  #   plug :fetch_session
  #   plug :fetch_flash
  #   plug :protect_from_forgery
  #   plug :put_secure_browser_headers
  # end

  pipeline :api_browser do
    # Not sure this is ok?
    # Mixing browser and api stuff does not seem right...
    plug(:accepts, ["html", "json"])
    plug(:fetch_session)
    plug(:fetch_flash)
    # plug(:protect_from_forgery)
    # plug(:put_secure_browser_headers)
    plug(MoodleNet.Plugs.Auth)
  end

  pipe_through(:api_browser)

  pipeline :ensure_authenticated do
    plug(MoodleNet.Plugs.EnsureAuthenticatedPlug)
  end

  scope "/api/v1" do
    resources("/users", MoodleNetWeb.Accounts.UserController, only: [:new, :create])
    resources("/sessions", MoodleNetWeb.Accounts.SessionController, only: [:new, :create])
  end

  scope "/api/v1" do
    pipe_through(:ensure_authenticated)

    resources("/sessions", MoodleNetWeb.Accounts.SessionController,
      only: [:delete],
      singleton: true
    )
  end

  pipeline :graphql do
    plug MoodleNet.Context
  end

  scope "/graphql" do
    pipe_through :graphql

    forward "/", Absinthe.Plug.GraphiQL,
    schema: MoodleNet.Schema,
    interface: :simple
  end


  scope "/oauth", MoodleNetWeb.OAuth do
    get("/authorize", OAuthController, :authorize)
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

  scope "/" do
    get "/", MoodleNetWeb.PageController, :index

    forward "/", ActivityPubWeb.Router
  end
end
