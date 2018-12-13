defmodule ActivityPub.ApplyAction do
  import ActivityPub.Guards
  alias ActivityPub.SQL.{CollectionStatement, Query}
  alias ActivityPub.SQLEntity

  def apply(entity) when not has_type(entity, "Activity"),
    do: raise(ArgumentError, "Only an Activity can be applied, received: #{inspect(entity.type)}")

  def apply(activity) when has_type(activity, "Activity") do
    with {:ok, activity} <- persist(activity),
         :ok <- side_effect(activity),
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
    following_collections =
      follow.actor
      |> Query.preload_assoc(:following)
      |> Enum.map(& &1.following)

    followers_collections =
      follow.object
      |> Query.preload_assoc(:followers)
      |> Enum.map(& &1.followers)

    CollectionStatement.add(following_collections, follow.object)
    CollectionStatement.add(followers_collections, follow.actor)

    :ok
  end

  # TODO
  defp insert_into_inbox(_activity) do
    :ok
  end

  # TODO
  defp insert_into_outbox(_activity) do
    :ok
  end

  defp federate(_activity) do
    :ok
  end
end
