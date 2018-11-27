defmodule MoodleNetTest do
  use MoodleNet.DataCase

  describe "create_community" do
    test "works" do
      attrs = Factory.attributes(:community)
      assert {:ok, community} = MoodleNet.create_community(attrs)
      assert community[:name] == %{"und" => attrs["name"]}
      assert community[:content] == %{"und" => attrs["content"]}
      assert community[:followers_count] == 0
      assert [icon] = community[:icon]
      assert [url] = icon[:url]
      assert url

      import Ecto.Query

      from( a in "activity_pub_icons",
           select: {a.target_id, a.subject_id})
           |> Repo.all()
           |> IO.inspect()
      a = ActivityPub.SQL.get_by_local_id(community[:local_id])
      |> ActivityPub.SQL.preload(:icon)
      |> IO.inspect()
    end
  end

  describe "create_collection" do
    test "works" do
      community = Factory.community()
      attrs = Factory.attributes(:collection)
      assert {:ok, collection} = MoodleNet.create_collection(community, attrs)
      assert collection[:name] == %{"und" => attrs["name"]}
      assert collection[:content] == %{"und" => attrs["content"]}
      assert [icon] = collection[:icon]
      assert [url] = icon[:url]
      assert url
    end
  end

  describe "create_resource" do
    test "works" do
      community = Factory.community()
      collection = Factory.collection(community)
      attrs = Factory.attributes(:resource)
      assert {:ok, resource} = MoodleNet.create_resource(collection, attrs)
      assert resource[:name] == %{"und" => attrs["name"]}
      assert resource[:content] == %{"und" => attrs["content"]}
    end
  end

  describe "create_comment" do
    test "works" do
      community = Factory.community()
      actor = Factory.actor()
      attrs = Factory.attributes(:comment)
      assert {:ok, comment} = MoodleNet.create_comment(actor, community, attrs)
      assert comment[:content] == %{"und" => attrs["content"]}
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

  describe "list_collections" do
    test "works" do
      community = Factory.community()
      collection = Factory.collection(community)

      community_2 = Factory.community()
      collection_2 = Factory.collection(community_2)

      assert [loaded_col] = MoodleNet.list_collections(community)
      assert collection[:local_id] == loaded_col[:local_id]

      assert [loaded_col] = MoodleNet.list_collections(community_2)
      assert collection_2[:local_id] == loaded_col[:local_id]

      assert [loaded_com] = MoodleNet.list_communities_with_collection(collection)
      assert community[:local_id] == loaded_com[:local_id]
    end
  end

  describe "list_resources" do
    test "works" do
      community = Factory.community()
      collection = Factory.collection(community)
      collection_2 = Factory.collection(community)

      resource = Factory.resource(collection)
      resource_2 = Factory.resource(collection_2)

      assert [loaded_col] = MoodleNet.list_resources(collection)
      assert resource[:local_id] == loaded_col[:local_id]

      assert [loaded_col] = MoodleNet.list_resources(collection_2)
      assert resource_2[:local_id] == loaded_col[:local_id]
    end
  end

  describe "list_comments" do
    test "works" do
      community = Factory.community()
      community_2 = Factory.community()
      actor = Factory.actor()
      actor_2 = Factory.actor()

      comment = Factory.comment(actor, community)
      comment_2 = Factory.comment(actor_2, community_2)

      assert [loaded_com] = MoodleNet.list_comments(%{context: community[:local_id]})
      assert comment[:local_id] == loaded_com[:local_id]

      assert [loaded_com] = MoodleNet.list_comments(%{context: community_2[:local_id]})
      assert comment_2[:local_id] == loaded_com[:local_id]

      assert [loaded_com] = MoodleNet.list_comments(%{attributed_to: actor[:local_id]})
      assert comment[:local_id] == loaded_com[:local_id]

      assert [loaded_com] = MoodleNet.list_comments(%{attributed_to: actor_2[:local_id]})
      assert comment_2[:local_id] == loaded_com[:local_id]
    end
  end
end
