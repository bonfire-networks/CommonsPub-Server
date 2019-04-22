defmodule ActivityPubWeb.Router do
  use ActivityPubWeb, :router

  pipeline :activity_pub do
    plug(:accepts, ["activity+json", "json"])
  end

  scope "/", ActivityPubWeb do
    pipe_through(:activity_pub)
    get "/:id", ActivityPubController, :show
    get "/:id/page", ActivityPubController, :collection_page
    post "/shared_inbox", ActivityPubController, :shared_inbox, as: :shared_inbox
  end
end
