defmodule ActivityPubWeb.ActivityPubController do
  use ActivityPubWeb, :controller

  import ActivityPub.Guards

  alias ActivityPub.SQL.Query

  def show(conn, %{"id" => id}) do
    id = String.to_integer(id)
    case ActivityPub.get_by_local_id(id) do
      nil ->
        send_resp(conn, :not_found, "")
      entity ->
        if ActivityPub.Entity.local?(entity) do
          entity =
            entity
            |> Query.preload_aspect(:all)
            |> Query.preload_assoc(:all)
          render(conn, "show.json", entity: entity)
        else
          send_resp(conn, :not_found, "")
        end
    end
  end
end
