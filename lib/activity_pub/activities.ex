defmodule ActivityPub.Activities do

  import ActivityPub.Guards
  alias ActivityPub.SQL.{Query, Alter}

  defguard is_likeable(object)
  when is_community(object)
  or   is_collection(object)
  or   is_resource(object)
  or   is_comment(object)
  or   is_person(object)

  defguard is_flaggable(object)
  when is_community(object)
  or   is_collection(object)
  or   is_resource(object)
  or   is_comment(object)
  or   is_person(object)

  def like(actor, thing) when is_person(actor) and is_likeable(thing) do
    actor = preload_followers(actor)
    thing = preload_for_like(thing)
    attrs = like_attrs(actor, thing)
    with :ok <- Policy.like(actor, comment, attrs),
         {:ok, activity} <- ActivityPub.new(attrs),
         {:ok, _activity} <- ActivityPub.apply(activity) do
      {:ok, true}
    end					 
  end

  def undo_like(actor, thing) when is_person(actor) and is_likeable(thing) do
  end

  def flag(actor, thing, reason) do
  end
  
  def undo_flag(actor, thing)

  def like_collection(actor, collection)
  when has_type(actor, "Person") and has_type(collection, "MoodleNet:Collection") do
    collection =
      Query.preload_assoc(collection, [:followers, context: [:followers]])
      |> Query.preload_aspect(:actor)

    [community] = collection.context

    attrs = %{
      type: "Like",
      actor: actor,
      object: collection,
      to: [Query.preload(actor.followers), collection, collection.followers, community.followers]
    }

    with {:ok, activity} = ActivityPub.new(attrs),
         {:ok, _activity} <- ActivityPub.apply(activity) do
      {:ok, true}
    end
  end

  # @doc """
  # Undoes a like of the collection.
  # Side Effects:
  # 1. Marks the like as deleted
  # 2. Publishes an AP unlike message to the relevant inboxes
  # """
  # def undo_like_collection(actor, collection) do
  #   Repo.transaction fn ->
  #     case Repo.get_by(CollectionLike
  #     with {:ok, true} <- MoodleNet.undo_like(actor, collection),
  #          {:ok, _like} <- Repo.delete(
  #     else
  # 	{:error, other} -> Repo.rollback(other)
  #       other -> Repo.rollback(other)
  #     end
  #   end
  # end

  defp preload_for_like(collection) when is_collection(collection) do
    collection
    |> Query.preload_assoc([:followers, context: [:followers]])
    |> Query.preload_aspect(:actor)
  end

  defp preload_for_like(resource) when is_resource(resource) do
    MoodleNet.preload_community(resource)
  end

  defp preload_for_like(comment) when is_comment(comment) do
    Query.preload_assoc(comment, [:attributed_to, context: [:followers, :context]])
  end

  defp preload_for_like(thing) when is_likeable(thing), do: thing

  defp like_attrs(actor, community) when is_community(community) do
    
  end

  defp like_attrs(actor, collection) when is_collection(collection) do
    
  end

  defp like_attrs(actor, resource) when is_resource(resource) do
    [collection] = resource.context
    collection = preload_followers(collection)
    community = get_community(preload_community(collection))
    attrs = %{
      type: "Like",
      actor: actor,
      object: resource,
      to: [collection, collection.followers, actor.followers]
    }
  end

  defp like_attrs(actor, comment) when is_comment(comment) do
    [attributed_to] = comment.attributed_to
    [context] = comment.context
    attrs = %{
      type: "Like",
      _public: true,
      actor: actor,
      object: comment,
      to: [actor.followers, attributed_to, context, context.followers]
    }
  end

  defp like_attrs(actor, thing) when is_likeable(thing) do

  end

  defp preload_followers(thing), do: Query.preload_assoc(thing, :followers)
  
  

end
