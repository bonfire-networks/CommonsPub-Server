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
      |> Map.put(:attributed_to, [collection])

    with {:ok, entity} <- ActivityPub.new(attrs) do
      ActivityPub.insert(entity)
    end
  end

  def create_thread(author, context, attrs)
      when has_type(author, "Person") and has_type(context, "MoodleNet:Community")
      when has_type(author, "Person") and has_type(context, "MoodleNet:Collection") do
    attrs
    |> Map.put(:context, context)
    |> Map.put(:attributed_to, author)
    |> create_comment()
  end

  def create_reply(author, in_reply_to, attrs)
      when has_type(author, "Person") and has_type(in_reply_to, "Note") do
    context = Query.new() |> Query.belongs_to(:context, in_reply_to) |> Query.one()

    attrs
    |> Map.put(:context, context)
    |> Map.put(:in_reply_to, in_reply_to)
    |> Map.put(:attributed_to, author)
    |> create_comment()
  end

  defp create_comment(attrs) do
    attrs = attrs |> Map.put("type", "Note")

    with {:ok, entity} <- ActivityPub.new(attrs) do
      ActivityPub.insert(entity)
    end
  end
end
