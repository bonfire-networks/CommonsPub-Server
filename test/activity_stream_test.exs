defmodule ActivityStreamTest do
  use Pleroma.DataCase, async: true
  doctest ActivityStream
  alias Pleroma.Factory

  describe "object" do
    test "it ensures uniqueness of the id" do
      object = Factory.insert(:note)
      {:error, cs} = ActivityStream.create_object(%{id: object.data["id"]})
      refute cs.valid?
    end
  end
end
