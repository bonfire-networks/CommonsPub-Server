defmodule ActivityPub.ApplyAction do
  import ActivityPub.Guards
  alias ActivityPub.SQL.{Alter}
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
    Alter.add(follow.actor, :following, follow.object)
    Alter.add(follow.object, :followers, follow.actor)

    :ok
  end

  defp side_effect(like) when has_type(like, "Like") do
    # FIXME verify type of actors
    Alter.add(like.actor, :liked, like.object)
    Alter.add(like.object, :likers, like.actor)

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
