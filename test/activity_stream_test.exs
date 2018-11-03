defmodule ActivityPubTest do
  use MoodleNet.DataCase, async: true
  doctest ActivityPub
  alias MoodleNet.Factory

  describe "object" do
    test "it ensures uniqueness of the id" do
      object = Factory.insert(:note)
      {:error, cs} = ActivityPub.create_object(%{id: object.data["id"]})
      refute cs.valid?
    end
  end
end
