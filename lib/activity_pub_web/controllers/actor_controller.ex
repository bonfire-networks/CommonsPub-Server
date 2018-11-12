defmodule ActivityPubWeb.ActorController do
  use ActivityPubWeb, :controller

  def show(conn, %{"id" => id}) do
    actor = ActivityPub.get_actor!(id)
    render(conn, :show, actor: actor)
  end
end
