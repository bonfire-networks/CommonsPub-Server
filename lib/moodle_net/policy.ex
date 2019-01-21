defmodule MoodleNet.Policy do
  import ActivityPub.Guards
  alias ActivityPub.SQL.Query

  def create_collection?(actor, community, _attrs)
      when has_type(community, "MoodleNet:Community") and has_type(actor, "Person") do
    actor_follows!(actor, community)
  end

  def create_resource?(actor, collection, _attrs)
      when has_type(collection, "MoodleNet:Collection") and has_type(actor, "Person") do
    community = get_community(collection)
    actor_follows!(actor, community)
  end

  def create_comment?(actor, community, _attrs)
      when has_type(community, "MoodleNet:Community") and has_type(actor, "Person") do
    actor_follows!(actor, community)
  end

  def create_comment?(actor, collection, _attrs)
      when has_type(collection, "MoodleNet:Collection") and has_type(actor, "Person") do
    community = get_community(collection)
    actor_follows!(actor, community)
  end

  def like_comment?(actor, comment, _attrs)
      when has_type(comment, "Note") and has_type(actor, "Person") do
    community = get_community(comment)
    actor_follows!(actor, community)
  end

  def like_resource?(actor, resource, _attrs)
      when has_type(resource, "MoodleNet:EducationalResource") and has_type(actor, "Person") do
    community = get_community(resource)
    actor_follows!(actor, community)
  end

  defp actor_follows!(actor, object) do
    if Query.has?(actor, :following, object), do: :ok, else: {:error, :forbidden}
  end

  defp get_community(comment) when has_type(comment, "Note") do
    [context] = comment.context
    get_community(context)
  end

  defp get_community(resource) when has_type(resource, "MoodleNet:EducationalResource") do
    [collection] = resource.attributed_to
    get_community(collection)
  end

  defp get_community(collection) when has_type(collection, "MoodleNet:Collection") do
    [community] = collection.attributed_to
    community
  end

  defp get_community(community) when has_type(community, "MoodleNet:Community"), do: community
end
