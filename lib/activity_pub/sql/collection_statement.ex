defmodule ActivityPub.SQL.CollectionStatement do
  import ActivityPub.Guards
  alias MoodleNet.Repo

  def add(collection, _) when not has_status(collection, :loaded),
    do: raise ArgumentError, "collection must be loaded"

  def add(_, item) when not has_status(item, :loaded),
    do: raise ArgumentError, "item must be loaded"

  def add(collection, item) when has_type(collection, "Collection") and is_entity(item) do
    c_id = ActivityPub.Entity.local_id(collection)
    i_id = ActivityPub.Entity.local_id(item)

    data = %{subject_id: c_id, target_id: i_id}
    opts = [on_conflict: :nothing]
    # FIXME ? what about foreign key?
    {insertion_number, nil} = Repo.insert_all("activity_pub_collections_items", [data], opts)
    insertion_number
  end

  def in?(collection, item) when has_type(collection, "Collection") and is_entity(item) do
    query(collection, item) |> Repo.exists?()
  end

  def remove(collection, item) when has_type(collection, "Collection") and is_entity(item) do
    {deletion_number, nil} = query(collection, item) |> Repo.delete_all()
    deletion_number
  end

  defp query(collection, item) do
    c_id = ActivityPub.Entity.local_id(collection)
    i_id = ActivityPub.Entity.local_id(item)

    import Ecto.Query, only: [from: 2]
    from rel in "activity_pub_collections_items",
      where: rel.subject_id == ^c_id and rel.target_id == ^i_id
  end
end
