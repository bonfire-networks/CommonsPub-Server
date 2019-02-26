defmodule ActivityPub.ApplyAction do
  import ActivityPub.Guards
  alias ActivityPub.SQL.{Alter}
  alias ActivityPub.SQLEntity

  def apply(entity) when not has_type(entity, "Activity"),
    do:
      raise(
        ArgumentError,
        "Action can only be applied on an Activity, but received: #{inspect(entity.type)}"
      )

  def apply(activity) when has_type(activity, "Activity") do
    with {:ok, activity} <- persist(activity),
         {:ok, activity} <- side_effect(activity),
         :ok <- insert_into_inbox(activity),
         :ok <- insert_into_outbox(activity),
         :ok <- federate(activity),
         do: {:ok, activity}
  end

  defp persist(activity) when has_status(activity, :new),
    do: SQLEntity.insert(activity)

  defp persist(activity) when has_status(activity, :loaded),
    do: {:ok, activity}

  defp side_effect(follow) when has_type(follow, "Follow") do
    # FIXME verify type of actors and objects
    Alter.add(follow.actor, :following, follow.object)
    Alter.add(follow.object, :followers, follow.actor)

    {:ok, follow}
  end

  defp side_effect(like) when has_type(like, "Like") do
    # FIXME verify type of actors
    Alter.add(like.actor, :liked, like.object)
    Alter.add(like.object, :likers, like.actor)

    {:ok, like}
  end

  defp side_effect(undo = %{object: [like]})
       when has_type(undo, "Undo") and has_type(like, "Like") do
    Alter.remove(like.actor, :liked, like.object)
    Alter.remove(like.object, :likers, like.actor)

    {:ok, undo}
  end

  defp side_effect(undo = %{object: [follow]})
       when has_type(undo, "Undo") and has_type(follow, "Follow") do
    Alter.remove(follow.actor, :following, follow.object)
    Alter.remove(follow.object, :followers, follow.actor)

    {:ok, undo}
  end

  defp side_effect(create) when has_type(create, "Create"), do: {:ok, create}

  defp side_effect(update = %{object: [object], _changes: changes = %{}})
       when has_type(update, "Update") do
    with {:ok, object} <- ActivityPub.update(object, changes) do
      {:ok, %{update | object: [object]}}
    end
  end

  defp side_effect(activity), do: {:ok, activity}

  # TODO
  defp insert_into_inbox(activity) do
    {people, collections} =
      [activity.to, activity.bto, activity.cc, activity.bcc, activity.audience]
      |> Enum.concat()
      |> Enum.split_with(fn
        dest when has_type(dest, "Person") -> true
        dest when has_type(dest, "Collection") -> false
        dest -> raise "Invalid destination #{inspect(dest)}"
      end)

    Alter.add(people, :inbox, activity)

    insert_into_inbox_collections(collections, ActivityPub.local_id(activity))
    :ok
  end

  defp insert_into_inbox_collections([], _), do: {:ok, 0}

  defp insert_into_inbox_collections(collections, activity_id) do
    collection_ids = Enum.map(collections, &ActivityPub.SQL.Common.local_id/1)
    sql_array = "'{#{Enum.join(collection_ids, ",")}}'"

    select = """
    SELECT a1."inbox_id", #{activity_id}::bigint FROM "activity_pub_collection_items"
    AS a0 INNER JOIN "activity_pub_actor_aspects" AS a1
    ON a1."local_id" = a0."target_id"
    WHERE (a0."subject_id" = ANY(#{sql_array}))
    """

    query =
      "INSERT INTO activity_pub_collection_items (subject_id, target_id) #{select}" <>
        "ON CONFLICT (subject_id, target_id) DO NOTHING;"

    %{num_rows: rows} = Ecto.Adapters.SQL.query!(MoodleNet.Repo, query, [])
    {:ok, rows}
  end

  defp insert_into_outbox(activity) do
    Alter.add(activity.actor, :outbox, activity)
    :ok
  end

  defp federate(_activity) do
    :ok
  end
end
