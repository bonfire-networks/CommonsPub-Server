defmodule ActivityPub.SQL do
  alias ActivityPub.{Entity, Metadata}

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
    e = persist_assocs(e)
    object_ch = SQLObject.create_changeset(e)

    Multi.new()
    |> Multi.insert(:_object, object_ch)
    |> Multi.run(:object, fn repo, %{_object: object} ->
      if object.id do
        {:ok, object}
      else
        object
        |> SQLObject.set_id_changeset()
        |> repo.update()
      end
    end)
    |> Multi.run(:actor, fn repo, %{object: sql_object} ->
      if ch = SQLActorAspect.create_changeset(sql_object, e) do
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
                     |> join_assocs(e)
        {:ok, new_entity}
      e -> e
    end
  end

  defp join_result(%{object: object} = result) do
    object
    |> Map.put(:actor, result.actor)
  end

  def join_assocs(new_entity, old_entity) do
    new_entity
    |> put_in([:attributed_to], old_entity[:attributed_to])
  end

  defp persist_assocs(entity) do
    entity
    |> persist_attributed_to()
  end

  defp persist_attributed_to(e) do
    persisted_attributed_to = Enum.map(e[:attributed_to], fn e ->
      {:ok, persisted} = persist(e)
      persisted
    end)
    
    put_in(e, [:attributed_to], persisted_attributed_to)
  end

  def load(local_id) do
    {:ok, SQLObject
    |> Repo.get_by(local_id: local_id)
    |> Repo.preload(:actor)
    |> to_entity()}
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
    |> Map.put(:metadata, Metadata.build(sql.type, :loaded, sql))
  end

  def preload(%Entity{metadata: %{sql: sql}} = e, list) do
    list = List.wrap(list)
    preload = Enum.map(list, & {&1, [:actor]})
    sql = Repo.preload(sql, preload)

    Enum.reduce(list, e, fn field_name, e ->
      assocs = sql
               |> Map.get(field_name)
               |> Enum.map(&to_entity/1)
      put_in(e, [field_name], assocs)
    end)
  end
end
