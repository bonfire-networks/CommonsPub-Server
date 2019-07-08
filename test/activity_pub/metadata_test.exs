# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule ActivityPub.MetadataTest do
  use MoodleNet.DataCase, async: true

  alias ActivityPub.Metadata

  test "new" do
    types = ["Activity", "CustomFollowType", "Follow", "Object"]
    metadata = Metadata.new(types)
    assert metadata.status == :new
    assert metadata.persistence == nil
    assert metadata.verified
    assert metadata.local
  end

  test "aspects" do
    metadata = Metadata.new(["Object", "Activity"])
    assert Metadata.aspects(metadata) == [
      ActivityPub.ActivityAspect,
      ActivityPub.ObjectAspect
    ]
  end

  test "types" do
    types = ["Activity", "CustomFollowType", "Follow", "Object"]
    metadata = Metadata.new(types)
    assert Metadata.types(metadata) == types
  end

  test "not_loaded" do
    assert %Metadata{
      status: :not_loaded,
      verified: false,
      local_id: nil
    } = Metadata.not_loaded(nil)

    assert %Metadata{
      status: not_loaded,
      verified: true,
      local_id: 25
    } = Metadata.not_loaded(25)
  end

  test "local_id" do
    assert Metadata.local_id(Metadata.not_loaded(nil)) == nil
    assert Metadata.local_id(Metadata.not_loaded(25)) == 25
  end

  test "local?" do
    metadata = Metadata.new([])
    assert Metadata.local?(%Metadata{metadata | local: true})
    refute Metadata.local?(%Metadata{metadata | local: false})
  end

  test "load" do
    entity_map = %{
      type: "Person",
      name: "Jenkins",
      preferred_username: "jenkins"
    }
    assert {:ok, entity} = ActivityPub.Builder.new(entity_map)
    assert {:ok, sql_entity} = ActivityPub.SQLEntity.insert(entity)
    # FIXME: SQLEntity.insert actually calls Metadata.load, it doesn't return an SQLEntity,
    # FIXME: but rather a map representing an entity.
    # assert metadata = Metadata.load(sql_entity)
    assert metadata = sql_entity.__ap__
    assert metadata.status == :loaded
    assert metadata.local
    assert metadata.local_id
  end

  describe "guards" do
    defmodule Foo do
      import ActivityPub.Metadata.Guards
      alias ActivityPub.{ObjectAspect, ActorAspect}

      def is_meta(o) when is_metadata(o), do: true
      def is_meta(_), do: false

      def has_object_type(o) when has_type(o, "Object"), do: true
      def has_object_type(_), do: false

      def has_actor_type(o) when has_type(o, "Actor"), do: true
      def has_actor_type(_), do: false

      def has_object_aspect(o) when has_aspect(o, ObjectAspect), do: true
      def has_object_aspect(_), do: false

      def has_actor_aspect(o) when has_aspect(o, ActorAspect), do: true
      def has_actor_aspect(_), do: false

      def local_id?(o) when has_local_id(o), do: true
      def local_id?(_), do: false
    end

    test "is_metadata guard works" do
      no_meta = Map.from_struct(Metadata.not_loaded())
      meta = Metadata.not_loaded()

      assert Foo.is_meta(meta)
      refute Foo.is_meta(no_meta)
    end

    test "has_type guard works" do
      object = Metadata.new(["Object"])
      person = Metadata.new(["Object", "Actor", "Person"])
      link = Metadata.new(["Link"])

      assert Foo.has_object_type(object)
      assert Foo.has_object_type(person)
      refute Foo.has_object_type(link)

      refute Foo.has_actor_type(object)
      assert Foo.has_actor_type(person)
      refute Foo.has_actor_type(link)
    end

    test "has_aspect guard works" do
      object = Metadata.new(["Object"])
      person = Metadata.new(["Object", "Actor", "Person"])
      link = Metadata.new(["Link"])

      assert Foo.has_object_aspect(object)
      assert Foo.has_object_aspect(person)
      refute Foo.has_object_aspect(link)

      refute Foo.has_actor_aspect(object)
      assert Foo.has_actor_aspect(person)
      refute Foo.has_actor_aspect(link)
    end

    test "has_local_id guard work" do
      local_id = Metadata.not_loaded(1)
      no_local_id = Metadata.not_loaded()

      assert Foo.local_id?(local_id)
      refute Foo.local_id?(no_local_id)
    end
  end
end
