# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

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


  @doc """
  Persist an Activity

  `ActivityPub.Entity` (and related modules, such as this one) only work with `Entities` in memory during runtime. Persistence is a separate layer, so in theory, this would allow creating other persistence layers using different types of storage — for example, graph databases.

  Our current persistence layer is `ActivityPub.SQLEntity` which uses Ecto and Postgres.

  It is important to understand that `ActivityPub.SQLEntity` and `ActivityPub.Entity` are completely separate modules with completely separate functionality:

  * `ActivityPub.SQLEntity` receives an `ActivityPub.Entity` and stores it in the database.

  * When something is loaded from the database, `ActivityPub.SQLEntity` returns an `ActivityPub.Entity`.

  * `ActivityPub.SQLEntity` knows about `ActivityPub.Entity`, but `ActivityPub.Entity` shouldn’t know anything about `ActivityPub.SQLEntity` (apart from knowing the names of modules to use persistence of course).
  """
  def persist(activity) when has_status(activity, :new),
    do: SQLEntity.insert(activity)

  def persist(activity) when has_status(activity, :loaded),
    do: {:ok, activity}


  @doc """
  Apply side effects of an Activity

  ActivityPub is a protocol in which all federated messages are _Activities_. Activities may trigger operations (which we also call *side effects*).

  In order to create the generic library we wanted to perform these operations in a generic way — adding hooks to customize some _Activities_. Some _Activities_ — _Like, Follow, Create_ and _Update_ — are implemented here.

  The `apply/1` function can be called by the MoodleNet module to add more functionality (instead of having to use hooks), for example in `MoodleNet.create_collection/3`.

  """
  def side_effect(follow) when has_type(follow, "Follow") do
    # FIXME verify type of actors and objects
    Alter.add(follow.actor, :following, follow.object)
    Alter.add(follow.object, :followers, follow.actor)

    {:ok, follow}
  end

  def side_effect(like) when has_type(like, "Like") do
    # FIXME verify type of actors
    Alter.add(like.actor, :liked, like.object)
    Alter.add(like.object, :likers, like.actor)

    {:ok, like}
  end

  def side_effect(undo = %{object: [like]})
       when has_type(undo, "Undo") and has_type(like, "Like") do
    Alter.remove(like.actor, :liked, like.object)
    Alter.remove(like.object, :likers, like.actor)

    {:ok, undo}
  end

  def side_effect(undo = %{object: [follow]})
       when has_type(undo, "Undo") and has_type(follow, "Follow") do
    Alter.remove(follow.actor, :following, follow.object)
    Alter.remove(follow.object, :followers, follow.actor)

    {:ok, undo}
  end

  def side_effect(create) when has_type(create, "Create"), do: {:ok, create}

  def side_effect(update = %{object: [object], _changes: changes = %{}})
       when has_type(update, "Update") do
    with {:ok, object} <- ActivityPub.update(object, changes) do
      {:ok, %{update | object: [object]}}
    end
  end

  def side_effect(activity), do: {:ok, activity}


  defp insert_into_inbox(activity) do
    {people, collections} =
      [activity.to, activity.bto, activity.cc, activity.bcc, activity.audience]
      |> Enum.concat()
      |> Enum.split_with(fn
        dest when has_type(dest, "Person") -> true
        dest when has_type(dest, "MoodleNet:Community") -> true
        dest when has_type(dest, "MoodleNet:Collection") -> true
        dest when has_type(dest, "Collection") -> false
        dest -> raise "Invalid destination #{inspect(dest)}"
      end)

    Alter.add(people, :inbox, activity)

    insert_into_inbox_collections(collections, ActivityPub.local_id(activity))
    :ok
  end

  defp insert_into_inbox_collections([], _), do: {:ok, 0}

  # FIXME - this should be an ActivityPub.SQL* modules
  defp insert_into_inbox_collections(collections, activity_id) do
    collection_ids = Enum.map(collections, &ActivityPub.SQL.Common.local_id/1)

    select = """
    SELECT a1."inbox_id", $1::bigint FROM "activity_pub_collection_items"
    AS a0 INNER JOIN "activity_pub_actor_aspects" AS a1
    ON a1."local_id" = a0."target_id"
    WHERE (a0."subject_id" = ANY($2))
    """

    query =
      "INSERT INTO activity_pub_collection_items (subject_id, target_id) #{select}" <>
        "ON CONFLICT (subject_id, target_id) DO NOTHING;"

    %{num_rows: rows} = Ecto.Adapters.SQL.query!(MoodleNet.Repo, query, [activity_id, collection_ids])
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
