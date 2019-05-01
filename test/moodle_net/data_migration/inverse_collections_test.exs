defmodule MoodleNet.DataMigration.InverseCollectionsTest do
  use MoodleNet.DataCase, async: true
  alias ActivityPub.SQL.{Query}

  test "works" do
    actor = Factory.actor()
    community = Factory.community(actor)
    collection = Factory.collection(actor, community)
    resource = Factory.resource(actor, collection)

    ActivityPub.delete(community.subcommunities)
    ActivityPub.delete(community.collections)
    ActivityPub.delete(collection.subcollections)
    ActivityPub.delete(collection.resources)

    community = Query.reload(community) |> Query.preload_assoc([:subcommunities, :collections])
    collection = Query.reload(collection) |> Query.preload_assoc([:subcollections, :resources])

    refute community.subcommunities
    refute community.collections
    refute collection.subcollections
    refute collection.resources

    MoodleNet.DataMigration.InverseCollections.call()

    community = Query.reload(community) |> Query.preload_assoc([:subcommunities, :collections])
    collection = Query.reload(collection) |> Query.preload_assoc([:context, :subcollections, :resources])

    assert community.subcommunities
    assert community.collections
    assert Query.has?(community, :collections, collection)

    assert collection.subcollections
    assert collection.resources
    assert Query.has?(collection, :resources, resource)
  end
end
