defmodule ActivityPubWeb.ActivityPubController do
  use ActivityPubWeb, :controller

  import ActivityPub.Guards

  alias ActivityPub.SQL.Query

  def show(conn, %{"id" => id}) do
    id = String.to_integer(id)
    case ActivityPub.get_by_local_id(id) do
      entity when is_local(entity) ->
        entity =
          entity
          |> Query.preload_aspect(:all)
          |> Query.preload_assoc(:all)
        render(conn, "show.json", entity: entity)
      _ ->
        send_resp(conn, :not_found, "")
    end
  end

  def collection_page(conn, %{"id" => id}) do
    id = String.to_integer(id)
    case ActivityPub.get_by_local_id(id) do
      collection when is_local(collection) and has_type(collection, "Collection") ->
        {:ok, entity} = ActivityPub.CollectionPage.new(collection, conn.query_params)
        render(conn, "show.json", entity: entity)
      _ ->
        send_resp(conn, :not_found, "")
    end
  end
end
