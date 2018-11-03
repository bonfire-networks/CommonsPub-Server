defmodule ActivityPubWeb.Router do
  use ActivityPubWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", ActivityPubWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  pipeline :read_activitypub do
    plug(:accepts, ["activity+json"])
  end

  pipeline :activitypub do
    plug(:accepts, ["activity+json"])
    plug(MoodleNetWeb.Plugs.HTTPSignaturePlug)
  end

  scope "/", ActivityPubWeb do
    pipe_through(:read_activitypub)

    get("/objects/:uuid", ActivityPubController, :object)
    get("/users/:nickname", ActivityPubController, :user)
    get("/users/:nickname/followers", ActivityPubController, :followers)
    get("/users/:nickname/following", ActivityPubController, :following)
    get("/users/:nickname/outbox", ActivityPubController, :outbox)
  end

  scope "/", ActivityPubWeb do
    pipe_through(:activitypub)
    post("/users/:nickname/inbox", ActivityPubController, :inbox)
    post("/inbox", ActivityPubController, :inbox)
  end
end
