defmodule ActivityPubWeb.Router do
  use ActivityPubWeb, :router

  pipeline :activitypub do
    plug(MoodleNetWeb.Plugs.HTTPSignaturePlug)
  end

  scope "/", ActivityPubWeb do
    resources("actors", ActorController, only: [:show])

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
