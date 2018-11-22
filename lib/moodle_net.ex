defmodule MoodleNet do
  import ActivityPub.Guards

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

  def list_collections(community, opts \\ %{}) do
    ActivityPub.SQL.query()
    |> ActivityPub.SQL.with_type("MoodleNet:Collection")
    |> ActivityPub.SQL.belongs_to(:attributed_to, community[:local_id])
    |> ActivityPub.SQL.paginate(opts)
    |> ActivityPub.SQL.all()
  end

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
end
