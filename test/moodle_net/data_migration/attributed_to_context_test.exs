defmodule MoodleNet.DataMigration.CreateGravatarIconTest do
  use MoodleNet.DataCase, async: true

  alias ActivityPub.SQL.{Alter}

  test "works" do
    actor = Factory.actor()
    community = Factory.community(actor)
    collection = Factory.collection(actor, community)
    resource = Factory.resource(actor, collection)

    Alter.remove(collection, :context, community)
    Alter.remove(collection, :attributed_to, actor)
    Alter.add(collection, :attributed_to, community)

    Alter.remove(resource, :context, collection)
    Alter.remove(resource, :attributed_to, actor)
    Alter.add(resource, :attributed_to, collection)

    MoodleNet.DataMigration.AttributedToContext.call()
  end
end
