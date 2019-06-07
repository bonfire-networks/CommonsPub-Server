# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule ActivityPub.ActivityPubControllerTest do
  use MoodleNetWeb.ConnCase

  @moduletag format: :activity
  defp last_activity(type) do
    alias ActivityPub.SQL.Query
    Query.new()
    |> Query.with_type(type)
    |> Query.last()
  end

  defp equal_list(a, b), do: MapSet.equal?(MapSet.new(a), MapSet.new(b)) == true

  @public "https://www.w3.org/ns/activitystreams#Public"
  @context [
    "https://www.w3.org/ns/activitystreams",
    "https://w3id.org/security/v1",
    %{
      "MoodleNet" => "http://vocab.moodle.net/",
      "@language" => "en",
      "Emoji" => "toot:Emoji",
      "Hashtag" => "as:Hashtag",
      "PropertyValue" => "schema:PropertyValue",
      "manuallyApprovesFollowers" => "as:manuallyApprovesFollowers",
      "schema" => "http://schema.org",
      "toot" => "http://joinmastodon.org/ns#",
      "totalItems" => "as:totalItems",
      "value" => "schema:value",
      "sensitive" => "as:sensitive"
    }
  ]

  test "show", %{conn: conn} do
    assert get(conn, "/activity_pub/404")
           |> response(404)

    actor = Factory.actor()
    local_id = ActivityPub.local_id(actor)

    assert resp =
             conn
             |> get("/activity_pub/#{local_id}")
             |> json_response(200)

    assert resp["@context"] == @context
    assert resp["id"]
    assert resp["type"] == "Person"
    assert resp["followers"]
    assert resp["following"]
    assert resp["icon"]
    assert resp["liked"]
    assert resp["location"]
    assert resp["name"]
    assert resp["inbox"]
    assert resp["outbox"]
    assert resp["endpoints"]["sharedInbox"]
    assert resp["preferredUsername"]
    assert resp["summary"]

    community = Factory.community(actor)

    follow_community_act = last_activity("Follow")

    local_id = ActivityPub.local_id(follow_community_act)
    assert resp =
             conn
             |> get("/activity_pub/#{local_id}")
             |> json_response(200)

    assert resp["@context"] == @context
    assert resp["actor"] == actor.id
    assert resp["id"]
    assert resp["object"] == community.id
    assert actor.followers.id in resp["to"]
    assert community.followers.id in resp["to"]
    assert equal_list(resp["to"], [@public, actor.followers.id, community.id, community.followers.id])
    assert resp["type"] == "Follow"

    create_community_act = last_activity("Create")

    local_id = ActivityPub.local_id(create_community_act)
    assert resp =
             conn
             |> get("/activity_pub/#{local_id}")
             |> json_response(200)

    assert resp["@context"] == @context
    assert resp["actor"] == actor.id
    assert resp["id"]
    assert resp["object"] == community.id
    assert equal_list(resp["to"], [@public, actor.followers.id])
    assert resp["type"] == "Create"

    local_id = ActivityPub.local_id(community)

    assert resp =
             conn
             |> get("/activity_pub/#{local_id}")
             |> json_response(200)

    assert resp["@context"] == @context
    assert resp["attributedTo"] == actor.id
    assert resp["followers"] == community.followers.id
    assert resp["following"] == community.following.id
    assert resp["icon"]
    assert resp["liked"]
    assert resp["name"]
    assert resp["inbox"] == community.inbox.id
    assert resp["outbox"] == community.outbox.id
    assert resp["endpoints"]["sharedInbox"]
    assert resp["preferredUsername"]
    assert resp["summary"]
    assert resp["type"] == ["Group", "MoodleNet:Community"]
    assert resp["streams"]["collections"] == community.collections.id
    assert resp["streams"]["subcommunities"] == community.subcommunities.id

    collection = Factory.collection(actor, community)
    follow_collection_act = last_activity("Follow")

    local_id = ActivityPub.local_id(follow_collection_act)
    assert resp =
             conn
             |> get("/activity_pub/#{local_id}")
             |> json_response(200)

    assert resp["@context"] == @context
    assert resp["actor"] == actor.id
    assert resp["id"]
    assert resp["object"] == collection.id
    assert equal_list(resp["to"], [@public, actor.followers.id, collection.id, collection.followers.id, community.followers.id])
    assert resp["type"] == "Follow"

    create_collection_act = last_activity("Create")

    local_id = ActivityPub.local_id(create_collection_act)
    assert resp =
             conn
             |> get("/activity_pub/#{local_id}")
             |> json_response(200)

    assert resp["@context"] == @context
    assert resp["actor"] == actor.id
    assert resp["id"]
    assert resp["object"] == collection.id
    assert equal_list(resp["to"], [@public, actor.followers.id, community.id, community.followers.id])
    assert resp["type"] == "Create"

    local_id = ActivityPub.local_id(collection)

    assert resp =
             conn
             |> get("/activity_pub/#{local_id}")
             |> json_response(200)

    assert resp["@context"] == @context
    assert resp["context"] == community.id
    assert resp["attributedTo"] == actor.id
    assert resp["followers"] == collection.followers.id
    assert resp["following"] == collection.following.id
    assert resp["icon"]
    assert resp["liked"]
    assert resp["name"]
    assert resp["inbox"] == collection.inbox.id
    assert resp["outbox"] == collection.outbox.id
    assert resp["endpoints"]["sharedInbox"]
    assert resp["preferredUsername"]
    assert resp["summary"]
    assert resp["type"] == ["Group", "MoodleNet:Collection"]
    assert resp["streams"]["resources"] == collection.resources.id
    assert resp["streams"]["subcollections"] == collection.subcollections.id

    resource = Factory.resource(actor, collection)
    create_resource_act = last_activity("Create")

    local_id = ActivityPub.local_id(create_resource_act)
    assert resp =
             conn
             |> get("/activity_pub/#{local_id}")
             |> json_response(200)

    assert resp["@context"] == @context
    assert resp["actor"] == actor.id
    assert resp["id"]
    assert resp["object"] == resource.id
    assert equal_list(resp["to"], [@public, actor.followers.id, collection.id, collection.followers.id, community.id, community.followers.id])
    assert resp["type"] == "Create"

    local_id = ActivityPub.local_id(resource)

    assert resp =
             conn
             |> get("/activity_pub/#{local_id}")
             |> json_response(200)

    assert resp["@context"] == @context
    assert resp["context"] == collection.id
    assert resp["attributedTo"] == actor.id
    assert resp["icon"]
    assert resp["name"]
    assert resp["summary"]
    assert resp["type"] == ["Page", "MoodleNet:EducationalResource"]

    comment = Factory.comment(actor, community)
    create_note_act = last_activity("Create")

    local_id = ActivityPub.local_id(create_note_act)
    assert resp =
             conn
             |> get("/activity_pub/#{local_id}")
             |> json_response(200)

    assert resp["@context"] == @context
    assert resp["actor"] == actor.id
    assert resp["id"]
    assert resp["object"] == comment.id
    assert equal_list(resp["to"], [@public, actor.followers.id, community.id, community.followers.id])
    assert resp["type"] == "Create"

    local_id = ActivityPub.local_id(comment)

    assert resp =
             conn
             |> get("/activity_pub/#{local_id}")
             |> json_response(200)

    assert resp["@context"] == @context
    assert resp["context"] == community.id
    assert resp["attributedTo"] == actor.id
    assert resp["content"]
    assert resp["type"] == "Note"

    other_actor = Factory.actor()
    assert {:ok, _} = MoodleNet.join_community(other_actor, community)
    reply = Factory.reply(other_actor, comment)
    create_reply_act = last_activity("Create")

    local_id = ActivityPub.local_id(create_reply_act)
    assert resp =
             conn
             |> get("/activity_pub/#{local_id}")
             |> json_response(200)

    assert resp["@context"] == @context
    assert resp["actor"] == other_actor.id
    assert resp["id"]
    assert resp["object"] == reply.id
    assert equal_list(resp["to"], [@public, other_actor.followers.id, community.id, community.followers.id, actor.id])
    assert resp["type"] == "Create"

    local_id = ActivityPub.local_id(reply)

    assert resp =
             conn
             |> get("/activity_pub/#{local_id}")
             |> json_response(200)

    assert resp["@context"] == @context
    assert resp["context"] == community.id
    assert resp["attributedTo"] == other_actor.id
    assert resp["content"]
    assert resp["type"] == "Note"

    # Collection comment
    col_comment = Factory.comment(actor, collection)
    create_col_note_act = last_activity("Create")

    local_id = ActivityPub.local_id(create_col_note_act)
    assert resp =
             conn
             |> get("/activity_pub/#{local_id}")
             |> json_response(200)

    assert resp["@context"] == @context
    assert resp["actor"] == actor.id
    assert resp["id"]
    assert resp["object"] == col_comment.id
    assert equal_list(resp["to"], [@public, actor.followers.id, collection.id, collection.followers.id])
    assert resp["type"] == "Create"

    local_id = ActivityPub.local_id(col_comment)

    assert resp =
             conn
             |> get("/activity_pub/#{local_id}")
             |> json_response(200)

    assert resp["@context"] == @context
    assert resp["context"] == collection.id
    assert resp["attributedTo"] == actor.id
    assert resp["content"]
    assert resp["type"] == "Note"

    col_reply = Factory.reply(other_actor, col_comment)
    create_reply_act = last_activity("Create")

    local_id = ActivityPub.local_id(create_reply_act)
    assert resp =
             conn
             |> get("/activity_pub/#{local_id}")
             |> json_response(200)

    assert resp["@context"] == @context
    assert resp["actor"] == other_actor.id
    assert resp["id"]
    assert resp["object"] == col_reply.id
    assert equal_list(resp["to"], [@public, other_actor.followers.id, collection.id, collection.followers.id, actor.id])
    assert resp["type"] == "Create"

    local_id = ActivityPub.local_id(col_reply)

    assert resp =
             conn
             |> get("/activity_pub/#{local_id}")
             |> json_response(200)

    assert resp["@context"] == @context
    assert resp["attributedTo"] == other_actor.id
    assert resp["content"]
    assert resp["type"] == "Note"

    # Like

    assert {:ok, _} = MoodleNet.like_collection(actor, collection)
    like_collection_act = last_activity("Like")
    local_id = ActivityPub.local_id(like_collection_act)
    assert resp =
             conn
             |> get("/activity_pub/#{local_id}")
             |> json_response(200)

    assert resp["@context"] == @context
    assert resp["id"]
    assert resp["actor"] == actor.id
    assert resp["object"] == collection.id
    assert resp["type"] == "Like"
    assert equal_list(resp["to"], [@public, actor.followers.id, community.followers.id, collection.followers.id, collection.id])

    assert {:ok, _} = MoodleNet.like_resource(actor, resource)
    like_resource_act = last_activity("Like")
    local_id = ActivityPub.local_id(like_resource_act)
    assert resp =
             conn
             |> get("/activity_pub/#{local_id}")
             |> json_response(200)

    assert resp["@context"] == @context
    assert resp["id"]
    assert resp["actor"] == actor.id
    assert resp["object"] == resource.id
    assert resp["type"] == "Like"
    assert equal_list(resp["to"], [@public, actor.followers.id, collection.followers.id, collection.id])

    assert {:ok, _} = MoodleNet.like_comment(actor, reply)
    like_comment_act = last_activity("Like")
    local_id = ActivityPub.local_id(like_comment_act)
    assert resp =
             conn
             |> get("/activity_pub/#{local_id}")
             |> json_response(200)

    assert resp["@context"] == @context
    assert resp["id"]
    assert resp["actor"] == actor.id
    assert resp["object"] == reply.id
    assert resp["type"] == "Like"
    assert equal_list(resp["to"], [@public, actor.followers.id, community.id, community.followers.id, other_actor.id])

    # Update
    assert {:ok, _} = MoodleNet.update_collection(actor, collection, %{name: %{"und" => "Community"}})
    update_collection_act = last_activity("Update")
    local_id = ActivityPub.local_id(update_collection_act)
    assert resp =
             conn
             |> get("/activity_pub/#{local_id}")
             |> json_response(200)

    assert resp["@context"] == @context
    assert resp["id"]
    assert resp["actor"] == actor.id
    assert resp["object"] == collection.id
    assert resp["type"] == "Update"
    assert equal_list(resp["to"], [@public, actor.followers.id, community.id, community.followers.id, collection.id, collection.followers.id])

    assert {:ok, _} = MoodleNet.update_resource(actor, resource, %{name: %{"und" => "Community"}})
    update_resource_act = last_activity("Update")
    local_id = ActivityPub.local_id(update_resource_act)
    assert resp =
             conn
             |> get("/activity_pub/#{local_id}")
             |> json_response(200)

    assert resp["@context"] == @context
    assert resp["id"]
    assert resp["actor"] == actor.id
    assert resp["object"] == resource.id
    assert resp["type"] == "Update"
    assert equal_list(resp["to"], [@public, actor.followers.id, community.id, community.followers.id, collection.id, collection.followers.id])

    # Followers
    local_id = ActivityPub.local_id(community.followers)
    assert resp =
             conn
             |> get("/activity_pub/#{local_id}")
             |> json_response(200)

    assert resp["@context"] == @context
    assert resp["id"] == community.followers.id
    assert resp["type"] == "Collection"
    assert resp["first"]
    refute resp["items"]

    page_id = resp["first"]
    assert resp =
             conn
             |> get(page_id)
             |> json_response(200)

    assert resp["@context"] == @context
    assert resp["id"] == page_id
    assert resp["type"] == "CollectionPage"
    refute resp["first"]
    assert resp["items"] == [other_actor.id, actor.id]

    # Undo Like
    assert {:ok, _} = MoodleNet.undo_like(actor, collection)
    undo_like_collection_act = last_activity("Undo")
    local_id = ActivityPub.local_id(undo_like_collection_act)
    assert resp =
             conn
             |> get("/activity_pub/#{local_id}")
             |> json_response(200)

    assert resp["@context"] == @context
    assert resp["id"]
    assert resp["actor"] == actor.id
    assert resp["object"] == like_collection_act.id
    assert resp["type"] == "Undo"
    assert equal_list(resp["to"], [@public, community.id, collection.id])

    assert {:ok, _} = MoodleNet.undo_like(actor, resource)
    undo_like_resource_act = last_activity("Undo")
    local_id = ActivityPub.local_id(undo_like_resource_act)
    assert resp =
             conn
             |> get("/activity_pub/#{local_id}")
             |> json_response(200)

    assert resp["@context"] == @context
    assert resp["id"]
    assert resp["actor"] == actor.id
    assert resp["object"] == like_resource_act.id
    assert resp["type"] == "Undo"
    assert equal_list(resp["to"], [@public, community.id, actor.id])

    assert {:ok, _} = MoodleNet.undo_like(actor, reply)
    undo_like_comment_act = last_activity("Undo")
    local_id = ActivityPub.local_id(undo_like_comment_act)
    assert resp =
             conn
             |> get("/activity_pub/#{local_id}")
             |> json_response(200)

    assert resp["@context"] == @context
    assert resp["id"]
    assert resp["actor"] == actor.id
    assert resp["object"] == like_comment_act.id
    assert resp["type"] == "Undo"
    assert equal_list(resp["to"], [@public, community.id, other_actor.id])

    # Undo follow
    assert {:ok, _} = MoodleNet.undo_follow(actor, collection)
    undo_follow_collection_act = last_activity("Undo")
    local_id = ActivityPub.local_id(undo_follow_collection_act)
    assert resp =
             conn
             |> get("/activity_pub/#{local_id}")
             |> json_response(200)

    assert resp["@context"] == @context
    assert resp["id"]
    assert resp["actor"] == actor.id
    assert resp["object"] == follow_collection_act.id
    assert resp["type"] == "Undo"
    assert equal_list(resp["to"], [@public, collection.id])

    assert {:ok, _} = MoodleNet.undo_follow(actor, community)
    undo_follow_community_act = last_activity("Undo")
    local_id = ActivityPub.local_id(undo_follow_community_act)
    assert resp =
             conn
             |> get("/activity_pub/#{local_id}")
             |> json_response(200)

    assert resp["@context"] == @context
    assert resp["id"]
    assert resp["actor"] == actor.id
    assert resp["object"] == follow_community_act.id
    assert resp["type"] == "Undo"
    assert equal_list(resp["to"], [@public, community.id])
  end
end
