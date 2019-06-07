# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNet.DataMigration.InverseCollectionsTest do
  use MoodleNet.DataCase, async: true
  alias ActivityPub.SQL.{Query}

  test "works" do
    actor = Factory.actor()
    community = Factory.community(actor)
    collection = Factory.collection(actor, community)
    resource = Factory.resource(actor, collection)

    comm_thread = Factory.comment(actor, community)
    comm_reply = Factory.reply(actor, comm_thread)

    coll_thread = Factory.comment(actor, collection)
    coll_reply = Factory.reply(actor, coll_thread)

    ActivityPub.delete(community.subcommunities)
    ActivityPub.delete(community.collections)
    ActivityPub.delete(community.threads)
    ActivityPub.delete(collection.subcollections)
    ActivityPub.delete(collection.resources)
    ActivityPub.delete(collection.threads)

    community = Query.reload(community) |> Query.preload_assoc([:subcommunities, :collections, :threads])
    collection = Query.reload(collection) |> Query.preload_assoc([:subcollections, :resources, :threads])

    refute community.subcommunities
    refute community.collections
    refute community.threads
    refute collection.subcollections
    refute collection.resources
    refute collection.threads

    MoodleNet.DataMigration.InverseCollections.call()

    community = Query.reload(community) |> Query.preload_assoc([:subcommunities, :collections, :threads])
    collection = Query.reload(collection) |> Query.preload_assoc([:context, :subcollections, :resources, :threads])

    assert community.subcommunities
    assert community.collections
    assert community.threads
    assert Query.has?(community, :collections, collection)
    assert Query.has?(community, :threads, comm_thread)
    refute Query.has?(community, :threads, comm_reply)

    assert collection.subcollections
    assert collection.resources
    assert collection.threads
    assert Query.has?(collection, :resources, resource)
    assert Query.has?(collection, :threads, coll_thread)
    refute Query.has?(collection, :threads, coll_reply)
  end
end
