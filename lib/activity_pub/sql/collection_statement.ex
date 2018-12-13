# FIXME I don't like this name
defmodule ActivityPub.SQL.CollectionStatement do
  import ActivityPub.Guards
  alias MoodleNet.Repo

  import ActivityPub.Entity, only: [local_id: 1]

  def add(collection, _) when not has_status(collection, :loaded),
    do: raise(ArgumentError, "collection must be loaded")

  def add(_, item) when not has_status(item, :loaded),
    do: raise(ArgumentError, "item must be loaded")

  def add(collection, items) when has_type(collection, "Collection"), do: add([collection], items)
  def add(collections, item) when is_entity(item), do: add(collections, [item])

  def add(collections, items) when is_list(collections) and is_list(items) do
    # FIXME raise an error if it is not a collection
    # FIXME better is entity error?
    data =
      for collection <- collections,
          has_type(collection, "Collection"),
          item <- items,
          is_entity(item),
          do: %{subject_id: local_id(collection), target_id: local_id(item)}

    opts = [on_conflict: :nothing]
    # FIXME ? what about foreign key?
    {insertion_number, nil} = Repo.insert_all("activity_pub_collection_items", data, opts)
    insertion_number
  end

  def in?(collection, item) when has_type(collection, "Collection") and is_entity(item) do
    query(collection, item) |> Repo.exists?()
  end

  defp query(collection, item) do
    c_id = ActivityPub.Entity.local_id(collection)
    i_id = ActivityPub.Entity.local_id(item)

    import Ecto.Query, only: [from: 2]

    from(rel in "activity_pub_collection_items",
      where: rel.subject_id == ^c_id and rel.target_id == ^i_id
    )
  end

  def remove(collection, items) when has_type(collection, "Collection"), do: remove([collection], items)
  def remove(collections, item) when is_entity(item), do: remove(collections, [item])
  def remove(collections, items) when is_list(collections) and is_list(items) do
    {deletion_number, nil} = remove_query(collections, items) |> Repo.delete_all()
    deletion_number
  end

  defp remove_query(collections, items) do
    c_ids =
      for collection <- collections,
          has_type(collection, "Collection"),
      do: local_id(collection)

    i_ids =
      for item <- items,
      is_entity(item),
      do: local_id(item)

    import Ecto.Query, only: [from: 2]

    from(rel in "activity_pub_collection_items",
      where: rel.subject_id in ^c_ids and rel.target_id in ^i_ids
    )
  end
end
