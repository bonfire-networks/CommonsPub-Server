defmodule ActivityPub.MetadataTest do
  use MoodleNet.DataCase, async: true

  alias ActivityPub.Metadata

  describe "build" do
    test "works" do
      types = ["Object", "Activity", "Follow", "CustomFollowType"]

      assert %{
               is_actor: false,
               is_link: false,
               is_object: true,
               is_activity: true,
               is_follow: true
             } = Metadata.build(types)
    end
  end

  describe "add_type and remove_type" do
    test "works" do
      assert %{is_actor: false, is_object: false, is_person: true} =
               Metadata.add_type(%Metadata{}, "Person")

      assert %{is_actor: true, is_person: false} =
               Metadata.remove_type(%Metadata{is_actor: true, is_person: true}, "Person")
    end
  end
end
