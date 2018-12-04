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
    |> Query.belongs_to(:attributed_to, entity_id)
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
    |> Query.belongs_to(:context, entity_id)
    |> Query.paginate(opts)
    |> Query.all()
  end

  def list_resources(entity, opts) do
    list_resources(entity[:local_id], opts)
  end

  def list_comments(opts \\ %{}) do
    Query.new()
    |> Query.with_type("Note")
    |> list_comments_by_attributed_to(opts)
    |> list_comments_by_context(opts)
    # |> list_comments_by_in_reply_to(opts)
    |> Query.paginate(opts)
    |> Query.all()
  end

  def list_comments_by_attributed_to(query, %{attributed_to: id}) do
    Query.belongs_to(query, :attributed_to, id)
  end

  def list_comments_by_attributed_to(query, _), do: query

  def list_comments_by_context(query, %{context: id}) do
    Query.belongs_to(query, :context, id)
  end

  def list_comments_by_context(query, _), do: query

  # def list_comments_by_in_reply_to(query, %{in_reply_to: id}) do
  #   Query.belongs_to(query, :in_reply_to, id)
  # end

  # def list_comments_by_in_reply_to(query, _), do: query

  def create_community(attrs) do
    attrs = Map.put(attrs, "type", "MoodleNet:Community")

    with {:ok, entity} <- ActivityPub.new(attrs) do
      ActivityPub.insert(entity)
    end
  end

  # FIXME
  def create_collection(community, attrs) when has_type(community, "MoodleNet:Community") do
    attrs =
      attrs
      |> Map.put(:type, "MoodleNet:Collection")
      |> Map.put(:attributed_to, [community])

    with {:ok, entity} <- ActivityPub.new(attrs) do
      ActivityPub.insert(entity)
    end
  end

  def create_resource(collection, attrs) when has_type(collection, "MoodleNet:Collection") do
    attrs =
      attrs
      |> Map.put(:type, "MoodleNet:EducationalResource")
      |> Map.put(:context, [collection])

    with {:ok, entity} <- ActivityPub.new(attrs) do
      ActivityPub.insert(entity)
    end
  end

  def create_comment(author, context, attrs)
      when has_type(author, "Person") and
             (has_type(context, "MoodleNet:Community") or
                has_type(context, "MoodleNet:Collection")) do
    attrs =
      attrs
      |> Map.put("type", "Note")
      |> Map.put("context", [context])
      |> Map.put("attributed_to", [author])

    with {:ok, entity} <- ActivityPub.new(attrs) do
      ActivityPub.insert(entity)
    end
  end
end
