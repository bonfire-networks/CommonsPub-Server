defmodule MoodleNetTest do
  use MoodleNet.DataCase

  describe "create_community" do
    test "works" do
      attrs = Factory.attributes(:community)
      assert {:ok, community} = MoodleNet.create_community(attrs)
      assert community[:name] == %{"und" => attrs["name"]}
      assert community[:content] == %{"und" => attrs["content"]}
    end
  end

  describe "create_collection" do
    test "works" do
      community = Factory.community()
      attrs = Factory.attributes(:collection)
      assert {:ok, community} = MoodleNet.create_collection(community, attrs)
      assert community[:name] == %{"und" => attrs["name"]}
      assert community[:content] == %{"und" => attrs["content"]}
    end
  end
end
