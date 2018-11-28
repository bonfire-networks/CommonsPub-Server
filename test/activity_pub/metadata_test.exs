defmodule ActivityPub.MetadataTest do
  use MoodleNet.DataCase, async: true

  alias ActivityPub.Metadata

  describe "new" do
    test "works" do
      types = ["Object", "Activity", "Follow", "CustomFollowType"]
      aspects = [ActivityPub.ObjectAspect, ActivityPub.ActivityAspect]

      assert Metadata.new(types, aspects, :parsed)
    end
  end

  describe "inspect" do
    test "works" do
    end
  end

  test "is_metadata guard works" do
    defmodule IsMetadata do
      import ActivityPub.Metadata.Guards

      def is_meta(o) when is_metadata(o), do: true
      def is_meta(_), do: false
    end

    no_meta = Map.from_struct(%Metadata{})
    meta = %Metadata{}

    assert IsMetadata.is_meta(meta)
    refute IsMetadata.is_meta(no_meta)
  end

  test "has_type guard works" do
    defmodule HasType do
      import ActivityPub.Metadata.Guards

      def is_object(o) when has_type(o, "Object"), do: true
      def is_object(_), do: false

      def is_actor(o) when has_type(o, "Actor"), do: true
      def is_actor(_), do: false
    end

    object = Metadata.new(["Object"], [], :parsed)
    person = Metadata.new(["Object", "Actor", "Person"], [], :parsed)
    link = Metadata.new(["Link"], [], :parsed)

    assert HasType.is_object(object)
    assert HasType.is_object(person)
    refute HasType.is_object(link)

    refute HasType.is_actor(object)
    assert HasType.is_actor(person)
    refute HasType.is_actor(link)
  end

  test "has_aspect guard works" do
    alias ActivityPub.{LinkAspect, ObjectAspect, ActorAspect}

    defmodule HasAspect do
      import ActivityPub.Metadata.Guards

      def is_object(o) when has_aspect(o, ObjectAspect), do: true
      def is_object(_), do: false

      def is_actor(o) when has_aspect(o, ActorAspect), do: true
      def is_actor(_), do: false
    end

    object = Metadata.new([], [ObjectAspect], :parsed)
    person = Metadata.new([], [ObjectAspect, ActorAspect], :parsed)
    link = Metadata.new([], [LinkAspect], :parsed)

    assert HasAspect.is_object(object)
    assert HasAspect.is_object(person)
    refute HasAspect.is_object(link)

    refute HasAspect.is_actor(object)
    assert HasAspect.is_actor(person)
    refute HasAspect.is_actor(link)
  end
end
