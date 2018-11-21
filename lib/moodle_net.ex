defmodule MoodleNet do
  import ActivityPub.Guards

  def list_communities(opts \\ %{}) do
    ActivityPub.SQL.query()
    |> ActivityPub.SQL.with_type("MoodleNetCommunity")
    |> ActivityPub.SQL.paginate(opts)
    |> ActivityPub.SQL.all()
  end

  def list_collection(community, opts \\ %{}) do
    ActivityPub.SQL.query()
    |> ActivityPub.SQL.with_type("MoodleNetCollection")
    |> ActivityPub.SQL.with_relation(:attributed_to, community[:local_id])
    |> ActivityPub.SQL.paginate(opts)
    |> ActivityPub.SQL.all()
  end

  def create_community(attrs) do
    attrs = Map.put(attrs, "type", "MoodleNetCommunity")

    with {:ok, entity} <- ActivityPub.parse(attrs) do
      ActivityPub.persist(entity)
    end
  end

  def create_collection(community, attrs) when is_moodle_net_community(community) do
    attrs =
      attrs
      |> Map.put("type", "MoodleNetCollection")
      |> Map.put("attributed_to", [community])

    with {:ok, entity} <- ActivityPub.parse(attrs) do
      ActivityPub.persist(entity)
    end
  end
end
