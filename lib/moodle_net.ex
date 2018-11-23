defmodule MoodleNet do
  import ActivityPub.Guards

  def get_entity_by_id(local_id) do
    ActivityPub.SQL.get_by_local_id(local_id)
  end

  def list_communities(opts \\ %{}) do
    ActivityPub.SQL.query()
    |> ActivityPub.SQL.with_type("MoodleNet:Community")
    |> ActivityPub.SQL.paginate(opts)
    |> ActivityPub.SQL.all()
  end

  def list_communities_with_collection(collection, opts \\ %{}) do
    ActivityPub.SQL.query()
    |> ActivityPub.SQL.with_type("MoodleNet:Community")
    |> ActivityPub.SQL.has(:attributed_to, collection[:local_id])
    |> ActivityPub.SQL.paginate(opts)
    |> ActivityPub.SQL.all()
  end

  def list_collections(entity, opts \\ %{})
  def list_collections(entity_id, opts) when is_integer(entity_id) do
    ActivityPub.SQL.query()
    |> ActivityPub.SQL.with_type("MoodleNet:Collection")
    |> ActivityPub.SQL.belongs_to(:attributed_to, entity_id)
    |> ActivityPub.SQL.paginate(opts)
    |> ActivityPub.SQL.all()
  end

  def list_collections(entity, opts) do
    list_collections(entity[:local_id], opts)
  end

  def list_resources(entity_id, opts \\ %{})
  def list_resources(entity_id, opts) when is_integer(entity_id) do
    ActivityPub.SQL.query()
    |> ActivityPub.SQL.with_type("MoodleNet:EducationalResource")
    |> ActivityPub.SQL.belongs_to(:context, entity_id)
    |> ActivityPub.SQL.paginate(opts)
    |> ActivityPub.SQL.all()
  end

  def list_resources(entity, opts) do
    list_resources(entity[:local_id], opts)
  end

  def list_comments(opts \\ %{}) do
    ActivityPub.SQL.query()
    |> ActivityPub.SQL.with_type("Note")
    |> list_comments_by_attributed_to(opts)
    |> list_comments_by_context(opts)
    # |> list_comments_by_in_reply_to(opts)
    |> ActivityPub.SQL.paginate(opts)
    |> ActivityPub.SQL.all()
  end

  def list_comments_by_attributed_to(query, %{attributed_to: id}) do
    ActivityPub.SQL.belongs_to(query, :attributed_to, id)
  end
  def list_comments_by_attributed_to(query, _), do: query

  def list_comments_by_context(query, %{context: id}) do
    ActivityPub.SQL.belongs_to(query, :context, id)
  end
  def list_comments_by_context(query, _), do: query

  def list_comments_by_in_reply_to(query, %{in_reply_to: id}) do
    ActivityPub.SQL.belongs_to(query, :in_reply_to, id)
  end
  def list_comments_by_in_reply_to(query, _), do: query

  def create_community(attrs) do
    attrs = Map.put(attrs, "type", "MoodleNet:Community")

    with {:ok, entity} <- ActivityPub.parse(attrs) do
      ActivityPub.persist(entity)
    end
  end

  # FIXME
  # def create_collection(community, attrs) when is_moodle_net_community(community) do
  def create_collection(community, attrs) do
    attrs =
      attrs
      |> Map.put("type", "MoodleNet:Collection")
      |> Map.put("attributed_to", [community])

    with {:ok, entity} <- ActivityPub.parse(attrs) do
      ActivityPub.persist(entity)
    end
  end

  def create_resource(collection, attrs) do
    attrs =
      attrs
      |> Map.put("type", "MoodleNet:EducationalResource")
      |> Map.put("context", [collection])

    with {:ok, entity} <- ActivityPub.parse(attrs) do
      ActivityPub.persist(entity)
    end
  end

  def create_comment(author, context, attrs) do
    attrs =
      attrs
      |> Map.put("type", "Note")
      |> Map.put("context", [context])
      |> Map.put("attributed_to", [author])

    with {:ok, entity} <- ActivityPub.parse(attrs) do
      ActivityPub.persist(entity)
    end
  end
end
