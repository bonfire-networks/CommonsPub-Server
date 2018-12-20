defmodule MoodleNet do
  import ActivityPub.Guards
  alias ActivityPub.SQL.Query

  def list_communities(opts \\ %{}) do
    Query.new()
    |> Query.with_type("MoodleNet:Community")
    |> Query.paginate(opts)
    |> Query.all()
  end

  def list_communities_with_collection(collection, opts \\ %{}) do
    Query.new()
    |> Query.with_type("MoodleNet:Community")
    |> Query.has(:attributed_to, collection[:local_id])
    |> Query.paginate(opts)
    |> Query.all()
  end

  def list_collections(entity, opts \\ %{})

  def list_collections(entity_id, opts) when is_integer(entity_id) do
    Query.new()
    |> Query.with_type("MoodleNet:Collection")
    |> Query.has(:attributed_to, entity_id)
    |> Query.paginate(opts)
    |> Query.all()
  end

  def list_collections(entity, opts) do
    list_collections(entity[:local_id], opts)
  end

  def list_resources(entity_id, opts \\ %{})

  def list_resources(entity_id, opts) when is_integer(entity_id) do
    Query.new()
    |> Query.with_type("MoodleNet:EducationalResource")
    |> Query.has(:attributed_to, entity_id)
    |> Query.paginate(opts)
    |> Query.all()
  end

  def list_resources(entity, opts) do
    list_resources(ActivityPub.Entity.local_id(entity), opts)
  end

  def list_comments(context_id, opts \\ %{}) do
    Query.new()
    |> Query.with_type("Note")
    |> Query.has(:context, context_id)
    |> Query.paginate(opts)
    |> Query.all()
  end

  def list_replies(in_reply_to_id, opts \\ %{}) do
    Query.new()
    |> Query.with_type("Note")
    |> Query.has(:in_reply_to, in_reply_to_id)
    |> Query.paginate(opts)
    |> Query.all()
  end

  def create_community(attrs) do
    attrs = Map.put(attrs, "type", "MoodleNet:Community")

    with {:ok, entity} <- ActivityPub.new(attrs) do
      ActivityPub.insert(entity)
    end
  end

  def update_community(community, changes) do
    {icon_url, changes} = Map.pop(changes, :icon)
    icon = Query.new() |> Query.belongs_to(:icon, community) |> Query.one()

    # FIXME this should be a transaction
    with {:ok, _icon} <- ActivityPub.update(icon, url: icon_url) do
      ActivityPub.update(community, changes)
    end
  end

  def delete_community(_actor, community) do
    # FIXME this should be a transaction
    Query.new()
    |> Query.with_type("Note")
    |> Query.has(:context, community)
    |> Query.delete_all()

    community_local_id = ActivityPub.Entity.local_id(community)

    import Ecto.Query, only: [from: 2]

    from(entity in ActivityPub.SQLEntity,
      where: fragment("? @> array['MoodleNet:EducationalResource']", entity.type),
      join: collection_attributed_to in "activity_pub_object_attributed_tos",
      on: collection_attributed_to.subject_id == entity.local_id,
      join: community_attributed_to in "activity_pub_object_attributed_tos",
      on:
        collection_attributed_to.target_id == community_attributed_to.subject_id and
          community_attributed_to.target_id == ^community_local_id
    )
    |> MoodleNet.Repo.delete_all()

    from(entity in ActivityPub.SQLEntity,
      where: fragment("? @> array['Note']", entity.type),
      join: collection_context in "activity_pub_object_contexts",
      on: collection_context.subject_id == entity.local_id,
      join: community_attributed_to in "activity_pub_object_attributed_tos",
      on:
        collection_context.target_id == community_attributed_to.subject_id and
          community_attributed_to.target_id == ^community_local_id
    )
    |> MoodleNet.Repo.delete_all()

    Query.new()
    |> Query.with_type("MoodleNet:Collection")
    |> Query.has(:attributed_to, community)
    |> Query.delete_all()

    ActivityPub.delete(community, [:icon])
    :ok
  end

  def create_collection(community, attrs) when has_type(community, "MoodleNet:Community") do
    attrs =
      attrs
      |> Map.put(:type, "MoodleNet:Collection")
      |> Map.put(:attributed_to, [community])

    with {:ok, entity} <- ActivityPub.new(attrs) do
      ActivityPub.insert(entity)
    end
  end

  def update_collection(collection, changes) do
    {icon_url, changes} = Map.pop(changes, :icon)
    icon = Query.new() |> Query.belongs_to(:icon, collection) |> Query.one()

    # FIXME this should be a transaction
    with {:ok, _icon} <- ActivityPub.update(icon, url: icon_url) do
      ActivityPub.update(collection, changes)
    end
  end

  def delete_collection(_actor, collection) do
    # FIXME this should be a transaction
    Query.new()
    |> Query.with_type("Note")
    |> Query.has(:context, collection)
    |> Query.delete_all()

    Query.new()
    |> Query.with_type("MoodleNet:EducationalResource")
    |> Query.has(:attributed_to, collection)
    |> Query.delete_all()

    ActivityPub.delete(collection, [:icon])
    :ok
  end

  def create_resource(_actor, collection, attrs)
      when has_type(collection, "MoodleNet:Collection") do
    attrs =
      attrs
      |> Map.put(:type, "MoodleNet:EducationalResource")
      |> Map.put(:attributed_to, [collection])

    with {:ok, entity} <- ActivityPub.new(attrs) do
      ActivityPub.insert(entity)
    end
  end

  def update_resource(resource, changes) do
    {icon_url, changes} = Map.pop(changes, :icon)
    icon = Query.new() |> Query.belongs_to(:icon, resource) |> Query.one()

    # FIXME this should be a transaction
    with {:ok, _icon} <- ActivityPub.update(icon, url: icon_url) do
      ActivityPub.update(resource, changes)
    end
  end

  def delete_resource(_actor, resource) do
    ActivityPub.delete(resource, [:icon])
    :ok
  end

  def copy_resource(actor, resource, collection) do
    resource = resource
               |> Query.preload_aspect(:resource)
               |> Query.preload_assoc([:icon])

    attrs =
      Map.take(resource, [
        :name,
        :summary,
        :content,
        :url,
        :primary_language,
        :icon,
        :published,
        :updated,
        :same_as,
        :in_language,
        :public_access,
        :is_accesible_for_free,
        :license,
        :learning_resource_type,
        :educational_use,
        :time_required,
        :typical_age_range
      ])
    url = get_in(resource, [:icon, Access.at(0), :url])
    attrs = Map.put(attrs, :icon, %{type: "Image", url: url})
    create_resource(actor, collection, attrs)
  end

  def create_thread(author, context, attrs)
      when has_type(author, "Person") and has_type(context, "MoodleNet:Community")
      when has_type(author, "Person") and has_type(context, "MoodleNet:Collection") do
    attrs
    |> Map.put(:context, [context])
    |> Map.put(:attributed_to, [author])
    |> create_comment()
  end

  def create_reply(author, in_reply_to, attrs)
      when has_type(author, "Person") and has_type(in_reply_to, "Note") do
    context = Query.new() |> Query.belongs_to(:context, in_reply_to) |> Query.one()

    attrs
    |> Map.put(:context, [context])
    |> Map.put(:in_reply_to, [in_reply_to])
    |> Map.put(:attributed_to, [author])
    |> create_comment()
  end

  defp create_comment(attrs) do
    attrs = attrs |> Map.put("type", "Note")

    with {:ok, entity} <- ActivityPub.new(attrs) do
      ActivityPub.insert(entity)
    end
  end

  def delete_comment(actor, comment) do
    if Query.has?(comment, :attributed_to, actor) do
      ActivityPub.delete(comment)
    else
      {:error, "operation not allowed"}
    end
  end

  def follow(follower, following) do
    params = %{type: "Follow", actor: follower, object: following}

    with {:ok, activity} = ActivityPub.new(params),
         {:ok, _activity} <- ActivityPub.apply(activity) do
      {:ok, true}
    end
  end

  def like(liker, liked) do
    params = %{type: "Like", actor: liker, object: liked}

    with {:ok, activity} = ActivityPub.new(params),
         {:ok, _activity} <- ActivityPub.apply(activity) do
      {:ok, true}
    end
  end

  def undo_follow(follower, following) do
    with :ok <- find_current_relation(follower, :following, following),
         {:ok, follow} <- find_activity("Follow", follower, following),
         params = %{type: "Undo", actor: follower, object: follow},
         {:ok, activity} = ActivityPub.new(params),
         {:ok, _activity} <- ActivityPub.apply(activity) do
      {:ok, true}
    end
  end

  def undo_like(liker, liked) do
    with :ok <- find_current_relation(liker, :liked, liked),
         {:ok, like} <- find_activity("Like", liker, liked),
         params = %{type: "Undo", actor: liker, object: like},
         {:ok, activity} = ActivityPub.new(params),
         {:ok, _activity} <- ActivityPub.apply(activity) do
      {:ok, true}
    end
  end

  defp find_current_relation(subject, relation, object) do
    if Query.has?(subject, relation, object),
      do: :ok,
      else: {:error, "Not found previous activity"}
  end

  defp find_activity(type, actor, object) do
    Query.new()
    |> Query.with_type(type)
    |> Query.has(:actor, actor)
    |> Query.has(:object, object)
    |> Query.last()
    |> case do
      nil ->
        {:error, "Not found previous activity"}

      activity ->
        activity = Query.preload_assoc(activity, actor: {[:actor], []}, object: {[:actor], []})
        {:ok, activity}
    end
  end
end
