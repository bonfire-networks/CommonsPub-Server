defmodule MoodleNet do
  import ActivityPub.Guards

  def list_communities(opts \\ []) do
    # ActivityPub.Query.query()
    # |> ActivityPub.Query.where(type: "MoodleNetCommunity")
    # |> ActivityPub.Query.all()
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
