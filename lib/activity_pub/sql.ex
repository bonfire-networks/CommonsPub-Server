defmodule ActivityPub.SQL do
  alias ActivityPub.Entity

  alias ActivityPub.{
    ObjectAspect,
    ActorAspect,
    ActivityAspect,
    CollectionAspect
  }

  alias ActivityPub.{
    SQLObject,
    SQLActorAspect,
    SQLActivityAspect,
    SQLCollectionAspect
  }

  alias Ecto.Multi
  alias MoodleNet.Repo

  def persist(%Entity{} = e) do
    object_ch = SQLObject.create_changeset(e)

    Multi.new()
    |> Multi.insert(:object, object_ch)
    |> Multi.run(:actor, fn repo, %{object: %{local_id: local_id}} ->
      if ch = SQLActorAspect.create_changeset(local_id, e) do
        repo.insert(ch)
      else
        {:ok, nil}
      end
    end)
    |> Repo.transaction()
    |> case do
      {:ok, result} ->
        new_entity = result
        |> join_result()
        |> to_entity()
        {:ok, new_entity}
      e -> e
    end
  end

  def join_result(%{object: object} = result) do
    object
    |> Map.put(:actor, result.actor)
  end

  def load(local_id) do
    SQLObject
    |> Repo.get_by(local_id: local_id)
    |> Repo.preload(:actor)
    |> to_entity()
  end

  defp to_entity(%SQLObject{} = sql) do
    %Entity{
      id: sql.id,
      local_id: sql.local_id,
      type: sql.type,
      "@context": Map.get(sql, :"@context"),
      extension_fields: sql.extension_fields,
    }
    |> Map.put(:object, SQLObject.to_aspect(sql))
    |> Map.put(:actor, SQLActorAspect.to_aspect(sql.actor))
  end
end
