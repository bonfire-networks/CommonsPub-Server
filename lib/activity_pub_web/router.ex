defmodule ActivityPubWeb.Router do
  use ActivityPubWeb, :router

  pipeline :activitypub do
    plug(MoodleNetWeb.Plugs.HTTPSignaturePlug)
  end

  scope "/", ActivityPubWeb do
    resources("/actors", ActorController, only: [:show])
  end
end
