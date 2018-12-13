defmodule ActivityPub.MetadataTest do
  use MoodleNet.DataCase, async: true

  alias ActivityPub.Metadata

  describe "new" do
    test "works" do
      types = ["Object", "Activity", "Follow", "CustomFollowType"]

      assert Metadata.new(types)
    end
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
  end
end
