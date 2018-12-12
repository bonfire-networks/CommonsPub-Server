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
    # FIXME verify type of actor and object
    follower_actor = follow.actor |> Query.preload_assoc(:follower)
    following_actor = follow.object |> Query.preload_assoc(:following)

    CollectionStatement.add(follower_actor.follower, following_actor)
    CollectionStatement.add(following_actor.following, follower_actor)

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
