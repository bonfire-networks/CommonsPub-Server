defmodule MoodleNet.DataMigration.InverseCollections do
  alias MoodleNet.Repo

  def call() do
    add_subcommunities()
    add_collections()
    add_subcollections()
    add_resources()
    add_community_threads()
    add_collection_threads()
  end

  defp add_collections() do
    comm_ids = get_without_collection("MoodleNet:Community", :collections_id)

    Repo.transaction(fn ->
      Enum.each(comm_ids, fn comm_id ->
        new_collection = new_collection()
        new_collection_id = ActivityPub.local_id(new_collection)
        context_subject_ids = context_subjects(comm_id)
        add_ids_to_collection(new_collection_id, context_subject_ids)
        query = update_query(comm_id)
        {1, _} = Repo.update_all(query, set: [collections_id: new_collection_id])
      end)
    end)
  end

  defp add_subcommunities() do
    comm_ids = get_without_collection("MoodleNet:Community", :subcommunities_id)

    Repo.transaction(fn ->
      Enum.each(comm_ids, fn comm_id ->
        new_collection = new_collection()
        new_collection_id = ActivityPub.local_id(new_collection)
        query = update_query(comm_id)
        {1, _} = Repo.update_all(query, set: [subcommunities_id: new_collection_id])
      end)
    end)
  end

  defp add_community_threads() do
    comm_ids = get_without_collection("MoodleNet:Community", :threads_id)

    Repo.transaction(fn ->
      Enum.each(comm_ids, fn comm_id ->
        new_collection = new_collection()
        new_collection_id = ActivityPub.local_id(new_collection)
        thread_ids = context_threads(comm_id)
        add_ids_to_collection(new_collection_id, thread_ids)
        query = update_query(comm_id)
        {1, _} = Repo.update_all(query, set: [threads_id: new_collection_id])
      end)
    end)
  end

  defp add_subcollections() do
    coll_ids = get_without_collection("MoodleNet:Collection", :subcollections_id)

    Repo.transaction(fn ->
      Enum.each(coll_ids, fn coll_id ->
        new_collection = new_collection()
        new_collection_id = ActivityPub.local_id(new_collection)
        query = update_query(coll_id)
        {1, _} = Repo.update_all(query, set: [subcollections_id: new_collection_id])
      end)
    end)
  end

  defp add_resources() do
    coll_ids = get_without_collection("MoodleNet:Collection", :resources_id)

    Repo.transaction(fn ->
      Enum.each(coll_ids, fn coll_id ->
        new_collection = new_collection()
        new_collection_id = ActivityPub.local_id(new_collection)
        context_subject_ids = context_subjects(coll_id)
        add_ids_to_collection(new_collection_id, context_subject_ids)
        query = update_query(coll_id)
        {1, _} = Repo.update_all(query, set: [resources_id: new_collection_id])
      end)
    end)
  end

  defp add_collection_threads() do
    coll_ids = get_without_collection("MoodleNet:Collection", :threads_id)

    Repo.transaction(fn ->
      Enum.each(coll_ids, fn coll_id ->
        new_collection = new_collection()
        new_collection_id = ActivityPub.local_id(new_collection)
        thread_ids = context_threads(coll_id)
        add_ids_to_collection(new_collection_id, thread_ids)
        query = update_query(coll_id)
        {1, _} = Repo.update_all(query, set: [threads_id: new_collection_id])
      end)
    end)
  end

  defp get_without_collection(type, field) do
    import Ecto.Query

    from(entity in ActivityPub.SQLEntity,
      where: fragment("? @> array[?]", entity.type, ^type),
      where: is_nil(field(entity, ^field)),
      select: entity.local_id
    )
    |> Repo.all()
  end

  defp new_collection() do
    {:ok, new} = ActivityPub.new(%{type: "Collection"})
    {:ok, persisted} = ActivityPub.insert(new)
    persisted
  end

  defp update_query(local_id) do
    import Ecto.Query

    from(entity in ActivityPub.SQLEntity,
      where: entity.local_id == ^local_id
    )
  end

  defp context_subjects(target_id) do
    import Ecto.Query

    from(context_rel in "activity_pub_object_contexts",
      where: context_rel.target_id == ^target_id,
      select: context_rel.subject_id
    )
    |> Repo.all()
  end

  defp add_ids_to_collection(collection_id, ids) do
    entries = Enum.map(ids, &%{subject_id: collection_id, target_id: &1})
    Repo.insert_all("activity_pub_collection_items", entries)
  end

  defp context_threads(target_id) do
    import Ecto.Query

    from(entity in ActivityPub.SQLEntity,
      where: fragment("? @> array[?]", entity.type, "Note"),
      join: context_rel in fragment("activity_pub_object_contexts"),
      on: context_rel.subject_id == entity.local_id,
      where: context_rel.target_id == ^target_id,
      left_join: rel in fragment("activity_pub_object_in_reply_tos"),
      on: entity.local_id == rel.subject_id,
      where: is_nil(rel.target_id),
      select: entity.local_id
    )
    |> Repo.all()
  end
end
