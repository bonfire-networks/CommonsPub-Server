defmodule MoodleNetTest do
  use MoodleNet.DataCase

  describe "create_community" do
    test "works" do
      attrs = Factory.attributes(:community)
      assert {:ok, community} = MoodleNet.create_community(attrs)
      assert community[:name] == %{"und" => attrs["name"]}
      assert community[:content] == %{"und" => attrs["content"]}
      assert community[:followers_count] == 0
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

  describe "list_communities" do
    test "works" do
      community = Factory.community()
      collection = Factory.collection(community)

      assert [loaded_com] = MoodleNet.list_communities()
      assert loaded_com[:name] == community[:name]
      assert loaded_com[:content] == community[:content]
    end

    test "paginates" do
      community = Factory.community()
      community_2 = Factory.community()

      assert [loaded_com] = MoodleNet.list_communities(limit: 1)
      assert loaded_com[:name] == community_2[:name]
      assert loaded_com[:content] == community_2[:content]

      assert [loaded_com] = MoodleNet.list_communities(limit: 1, order: :asc)
      assert loaded_com[:name] == community[:name]
      assert loaded_com[:content] == community[:content]

      # assert [loaded_com] = MoodleNet.list_communities(limit: 1, order: :desc, starting_after: community_2[:local_id])
      # assert loaded_com[:name] == community[:name]
      # assert loaded_com[:content] == community[:content]

    end
  end
end
