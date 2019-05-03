defmodule MoodleNetTest do
  use MoodleNet.DataCase, async: true

  alias ActivityPub.SQL.Query

  describe "community" do
    test "create" do
      actor = Factory.actor()
      attrs = Factory.attributes(:community)

      assert {:ok, community} = MoodleNet.create_community(actor, attrs)

      assert community.name == %{"und" => attrs["name"]}
      assert community.summary == %{"und" => attrs["summary"]}
      assert community.content == %{"und" => attrs["content"]}
      assert community.preferred_username == attrs["preferred_username"]
      assert community["primary_language"] == attrs["primary_language"]
      url = get_in(community, [:icon, Access.at(0), :url, Access.at(0)])
      assert url == attrs["icon"]["url"]
    end

    test "join & undo" do
      actor = Factory.actor()
      comm = Factory.community(actor)

      actor = Factory.actor()
      assert {:error, {:not_found, _, "Activity"}} = MoodleNet.undo_follow(actor, comm)
      assert {:ok, true} = MoodleNet.join_community(actor, comm)
      assert {:ok, true} = MoodleNet.join_community(actor, comm)
      assert {:ok, true} = MoodleNet.undo_follow(actor, comm)
      assert {:error, {:not_found, _, "Activity"}} = MoodleNet.undo_follow(actor, comm)
    end

    test "thread list" do
      actor = Factory.actor()
      comm = Factory.community(actor)

      assert [] = MoodleNet.community_thread_list(comm)
      assert 0 = MoodleNet.community_thread_count(comm)

      %{id: id} = comment = Factory.comment(actor, comm)
      Factory.reply(actor, comment)
      assert [%{id: ^id}] = MoodleNet.community_thread_list(comm)
      assert 1 = MoodleNet.community_thread_count(comm)
    end

    test "member list" do
      %{id: actor_id} = actor = Factory.actor()
      comm = Factory.community(actor)

      assert [%{id: ^actor_id}] = MoodleNet.community_member_list(comm)
      assert 1 = MoodleNet.community_member_count(comm)
    end

    test "collection list" do
      actor = Factory.actor()
      comm = Factory.community(actor)

      assert [] = MoodleNet.community_collection_list(comm)
      assert 0 = MoodleNet.community_collection_count(comm)

      %{id: col_id} = Factory.collection(actor, comm)
      assert [%{id: ^col_id}] = MoodleNet.community_collection_list(comm)
      assert 1 = MoodleNet.community_collection_count(comm)
    end
  end

  describe "user comments" do
    test "works" do
      actor = Factory.actor()

      assert [] = MoodleNet.user_comment_list(actor)
      assert 0 = MoodleNet.user_comment_count(actor)

      comm = Factory.community(actor)
      a = %{id: a_id} = Factory.comment(actor, comm)
      %{id: b_id} = Factory.reply(actor, a)

      assert [%{id: ^b_id}, %{id: ^a_id}] = MoodleNet.user_comment_list(actor)
      assert 2 = MoodleNet.user_comment_count(actor)

      coll = Factory.community(actor)
      c = %{id: c_id} = Factory.comment(actor, coll)
      %{id: d_id} = Factory.reply(actor, c)

      assert [%{id: ^d_id}, %{id: ^c_id}, %{id: ^b_id}, %{id: ^a_id}] =
               MoodleNet.user_comment_list(actor)

      assert 4 = MoodleNet.user_comment_count(actor)
    end
  end

  describe "joined communities" do
    test "works" do
      actor = Factory.actor()
      %{id: comm_id} = comm = Factory.community(actor)

      assert [%{id: ^comm_id}] = MoodleNet.joined_communities_list(actor)

      assert {:ok, true} = MoodleNet.undo_follow(actor, comm)
      assert [] = MoodleNet.joined_communities_list(actor)
    end
  end

  describe "following collections" do
    test "works" do
      actor = Factory.actor()
      comm = Factory.community(actor)
      %{id: coll_id} = coll = Factory.collection(actor, comm)

      assert [%{id: ^coll_id}] = MoodleNet.following_collection_list(actor)
      assert 1 = MoodleNet.following_collection_count(actor)

      assert {:ok, true} = MoodleNet.undo_follow(actor, coll)
      assert [] = MoodleNet.following_collection_list(actor)
      assert 0 = MoodleNet.following_collection_count(actor)
    end
  end

  describe "collection follower" do
    test "works" do
      %{id: actor_id} = actor = Factory.actor()
      comm = Factory.community(actor)
      coll = Factory.collection(actor, comm)

      assert [%{id: ^actor_id}] = MoodleNet.collection_follower_list(coll)
      assert 1 = MoodleNet.collection_follower_count(coll)
    end
  end

  describe "collection resource" do
    test "works" do
      actor = Factory.actor()
      comm = Factory.community(actor)
      coll = Factory.collection(actor, comm)

      assert [] = MoodleNet.collection_resource_list(coll)
      assert 0 = MoodleNet.collection_resource_count(coll)

      %{id: id} = Factory.resource(actor, coll)
      assert [%{id: ^id}] = MoodleNet.collection_resource_list(coll)
      assert 1 = MoodleNet.collection_resource_count(coll)
    end
  end

  describe "collection thread" do
    test "works" do
      actor = Factory.actor()
      comm = Factory.community(actor)
      coll = Factory.collection(actor, comm)

      assert [] = MoodleNet.collection_thread_list(coll)
      assert 0 = MoodleNet.collection_thread_count(coll)

      %{id: id} = comment = Factory.comment(actor, coll)
      Factory.reply(actor, comment)
      assert [%{id: ^id}] = MoodleNet.collection_thread_list(coll)
      assert 1 = MoodleNet.collection_thread_count(coll)
    end
  end

  describe "collection likers" do
    test "works" do
      %{id: actor_id} = actor = Factory.actor()

      comm = Factory.community(actor)
      coll = Factory.collection(actor, comm)

      assert [] = MoodleNet.collection_liker_list(coll)
      assert 0 = MoodleNet.collection_liker_count(coll)

      MoodleNet.like_collection(actor, coll)
      assert [%{id: ^actor_id}] = MoodleNet.collection_liker_list(coll)
      assert 1 = MoodleNet.collection_liker_count(coll)
    end
  end

  describe "resource likers" do
    test "works" do
      %{id: actor_id} = actor = Factory.actor()

      comm = Factory.community(actor)
      coll = Factory.collection(actor, comm)
      res = Factory.resource(actor, coll)

      assert [] = MoodleNet.resource_liker_list(res)
      assert 0 = MoodleNet.resource_liker_count(res)

      MoodleNet.like_resource(actor, res)
      assert [%{id: ^actor_id}] = MoodleNet.resource_liker_list(res)
      assert 1 = MoodleNet.resource_liker_count(res)
    end
  end

  describe "comment replies" do
    test "works" do
      actor = Factory.actor()

      comm = Factory.community(actor)
      coll = Factory.collection(actor, comm)
      comment = Factory.comment(actor, coll)

      assert [] = MoodleNet.comment_reply_list(comment)
      assert 0 = MoodleNet.comment_reply_count(comment)

      %{id: reply_id} = Factory.reply(actor, comment)
      assert [%{id: ^reply_id}] = MoodleNet.comment_reply_list(comment)
      assert 1 = MoodleNet.comment_reply_count(comment)
    end
  end

  describe "comment likers" do
    test "works" do
      %{id: actor_id} = actor = Factory.actor()

      comm = Factory.community(actor)
      coll = Factory.collection(actor, comm)
      comment = Factory.comment(actor, coll)

      assert [] = MoodleNet.comment_liker_list(comment)
      assert 0 = MoodleNet.comment_liker_count(comment)

      MoodleNet.like_comment(actor, comment)
      assert [%{id: ^actor_id}] = MoodleNet.comment_liker_list(comment)
      assert 1 = MoodleNet.comment_liker_count(comment)
    end
  end

  describe "paginates" do
    test "by creation time" do
      actor = Factory.actor()
      comm = Factory.community(actor)
      a = Factory.comment(actor, comm)
      b = Factory.comment(actor, comm)
      a_id = a.id
      b_id = b.id

      opts = %{limit: 1}
      assert results = [%{id: ^b_id}] = MoodleNet.community_thread_list(comm, opts)
      assert page_info = MoodleNet.page_info(results, opts)
      assert page_info.older
      assert page_info.newer == nil

      opts = %{limit: 1, after: page_info.older}
      assert results = [%{id: ^a_id}] = MoodleNet.community_thread_list(comm, opts)
      assert page_info = MoodleNet.page_info(results, opts)
      assert page_info.older
      assert page_info.newer

      opts = %{limit: 1, after: page_info.older}
      assert results = [] = MoodleNet.community_thread_list(comm, opts)
      assert page_info = MoodleNet.page_info(results, opts)
      assert page_info.older == nil
      assert page_info.newer

      opts = %{limit: 1, before: page_info.newer}
      assert results = [%{id: ^a_id}] = MoodleNet.community_thread_list(comm, opts)
      assert page_info = MoodleNet.page_info(results, opts)
      assert page_info.older
      assert page_info.newer

      opts = %{limit: 1, before: page_info.newer}
      assert results = [%{id: ^b_id}] = MoodleNet.community_thread_list(comm, opts)
      assert page_info = MoodleNet.page_info(results, opts)
      assert page_info.older
      assert page_info.newer

      opts = %{limit: 1, before: page_info.newer}
      assert results = [] = MoodleNet.community_thread_list(comm, opts)
      assert page_info = MoodleNet.page_info(results, opts)
      assert page_info.older
      assert page_info.newer == nil

      opts = %{limit: 3}
      assert results = [%{id: ^b_id}, %{id: ^a_id}] = MoodleNet.community_thread_list(comm, opts)
      assert page_info = MoodleNet.page_info(results, opts)
      assert page_info.older == nil
      assert page_info.newer == nil
    end

    test "by collection insertion" do
      actor = Factory.actor()
      %{id: a_id} = a = Factory.community(actor)
      %{id: b_id} = b = Factory.community(actor)
      other_actor = Factory.actor()

      MoodleNet.join_community(other_actor, b)
      MoodleNet.join_community(other_actor, a)

      opts = %{limit: 1}
      assert results = [%{id: ^a_id}] = MoodleNet.joined_communities_list(other_actor, opts)
      assert page_info = MoodleNet.page_info(results, opts)
      assert page_info.older
      assert page_info.newer == nil

      opts = %{limit: 1, after: page_info.older}
      assert results = [%{id: ^b_id}] = MoodleNet.joined_communities_list(other_actor, opts)
      assert page_info = MoodleNet.page_info(results, opts)
      assert page_info.older
      assert page_info.newer

      opts = %{limit: 1, after: page_info.older}
      assert results = [] = MoodleNet.joined_communities_list(other_actor, opts)
      assert page_info = MoodleNet.page_info(results, opts)
      assert page_info.older == nil
      assert page_info.newer

      opts = %{limit: 1, before: page_info.newer}
      assert results = [%{id: ^b_id}] = MoodleNet.joined_communities_list(other_actor, opts)
      assert page_info = MoodleNet.page_info(results, opts)
      assert page_info.older
      assert page_info.newer

      opts = %{limit: 1, before: page_info.newer}
      assert results = [%{id: ^a_id}] = MoodleNet.joined_communities_list(other_actor, opts)
      assert page_info = MoodleNet.page_info(results, opts)
      assert page_info.older
      assert page_info.newer

      opts = %{limit: 1, before: page_info.newer}
      assert results = [] = MoodleNet.joined_communities_list(other_actor, opts)
      assert page_info = MoodleNet.page_info(results, opts)
      assert page_info.older
      assert page_info.newer == nil

      opts = %{limit: 3}

      assert results =
               [%{id: ^a_id}, %{id: ^b_id}] = MoodleNet.joined_communities_list(other_actor, opts)

      assert page_info = MoodleNet.page_info(results, opts)
      assert page_info.older == nil
      assert page_info.newer == nil
    end
  end

  describe "create_collection" do
    test "works" do
      actor = Factory.actor()
      comm = Factory.community(actor)

      attrs = Factory.attributes(:collection)
      actor = Factory.actor()
      assert {:error, :forbidden} = MoodleNet.create_collection(actor, comm, attrs)

      MoodleNet.join_community(actor, comm)

      assert {:ok, collection} = MoodleNet.create_collection(actor, comm, attrs)
      assert collection.name == %{"und" => attrs["name"]}
      assert collection.summary == %{"und" => attrs["summary"]}
      assert collection.content == %{"und" => attrs["content"]}
      assert collection.preferred_username == attrs["preferred_username"]
      assert collection["primary_language"] == attrs["primary_language"]
      url = get_in(collection, [:icon, Access.at(0), :url, Access.at(0)])
      assert url == attrs["icon"]["url"]
      assert Query.has?(comm, :collections, collection)
    end
  end

  describe "create_resource" do
    test "works" do
      actor = Factory.actor()
      comm = Factory.community(actor)
      coll = Factory.collection(actor, comm)

      attrs = Factory.attributes(:resource)

      actor = Factory.actor()
      assert {:error, :forbidden} = MoodleNet.create_resource(actor, coll, attrs)

      MoodleNet.join_community(actor, comm)

      assert {:ok, resource} = MoodleNet.create_resource(actor, coll, attrs)
      assert resource.name == %{"und" => attrs["name"]}
      assert resource.summary == %{"und" => attrs["summary"]}
      assert resource.content == %{"und" => attrs["content"]}
      assert resource.primary_language == attrs["primary_language"]
      url = get_in(resource, [:icon, Access.at(0), :url, Access.at(0)])
      assert url == attrs["icon"]["url"]
      assert resource.url == [attrs["url"]]
      assert resource.same_as == attrs["same_as"]
      assert resource.public_access == attrs["public_access"]
      assert resource.is_accesible_for_free == attrs["is_accesible_for_free"]
      assert resource.license == attrs["license"]
      assert resource.learning_resource_type == attrs["learning_resource_type"]
      assert resource.educational_use == attrs["educational_use"]
      assert resource.time_required == attrs["time_required"]
      assert resource.typical_age_range == attrs["typical_age_range"]
      assert Query.has?(coll, :resources, resource)
    end
  end

  describe "create_thread" do
    test "works" do
      actor = Factory.actor()
      comm = Factory.community(actor)
      coll = Factory.collection(actor, comm)

      attrs = Factory.attributes(:comment)

      actor = Factory.actor()
      assert {:error, :forbidden} = MoodleNet.create_thread(actor, comm, attrs)
      assert {:error, :forbidden} = MoodleNet.create_thread(actor, coll, attrs)

      MoodleNet.join_community(actor, comm)
      assert {:ok, comment} = MoodleNet.create_thread(actor, comm, attrs)
      assert comment["primary_language"] == attrs["primary_language"]
      assert comment.content == %{"und" => attrs["content"]}

      assert Query.has?(comm, :threads, comment)

      assert {:ok, comment} = MoodleNet.create_thread(actor, coll, attrs)
      assert comment["primary_language"] == attrs["primary_language"]
      assert comment.content == %{"und" => attrs["content"]}

      assert Query.has?(coll, :threads, comment)
    end
  end

  describe "create_reply" do
    test "works" do
      actor = Factory.actor()
      comm = Factory.community(actor)
      coll = Factory.collection(actor, comm)

      c1 = Factory.comment(actor, comm)
      c2 = Factory.comment(actor, coll)

      attrs = Factory.attributes(:comment)

      actor = Factory.actor()
      assert {:error, :forbidden} = MoodleNet.create_reply(actor, c1, attrs)
      assert {:error, :forbidden} = MoodleNet.create_reply(actor, c2, attrs)

      MoodleNet.join_community(actor, comm)
      assert {:ok, comment} = MoodleNet.create_reply(actor, c1, attrs)
      assert comment["primary_language"] == attrs["primary_language"]
      assert comment.content == %{"und" => attrs["content"]}

      assert {:ok, comment} = MoodleNet.create_reply(actor, c2, attrs)
      assert comment["primary_language"] == attrs["primary_language"]
      assert comment.content == %{"und" => attrs["content"]}
    end
  end

  describe "like_comment & undo" do
    test "works" do
      actor = Factory.actor()
      comm = Factory.community(actor)
      coll = Factory.collection(actor, comm)

      c1 = Factory.comment(actor, comm)
      c2 = Factory.comment(actor, coll)

      actor = Factory.actor()
      assert {:error, :forbidden} = MoodleNet.like_comment(actor, c1)
      assert {:error, :forbidden} = MoodleNet.like_comment(actor, c2)

      MoodleNet.join_community(actor, comm)

      assert {:ok, true} = MoodleNet.like_comment(actor, c1)
      assert {:ok, true} = MoodleNet.like_comment(actor, c2)

      assert {:ok, true} = MoodleNet.undo_like(actor, c1)
      assert {:ok, true} = MoodleNet.undo_like(actor, c2)

      assert {:error, {:not_found, _, "Activity"}} = MoodleNet.undo_like(actor, c1)
      assert {:error, {:not_found, _, "Activity"}} = MoodleNet.undo_like(actor, c2)
    end
  end

  describe "like_collection & undo" do
    test "works" do
      actor = Factory.actor()
      comm = Factory.community(actor)
      coll = Factory.collection(actor, comm)

      actor = Factory.actor()
      assert {:error, :forbidden} = MoodleNet.like_collection(actor, coll)

      MoodleNet.join_community(actor, comm)
      assert {:ok, true} = MoodleNet.like_collection(actor, coll)

      assert {:ok, true} = MoodleNet.undo_like(actor, coll)
      assert {:error, {:not_found, _, "Activity"}} = MoodleNet.undo_like(actor, coll)
    end
  end

  describe "like_resource & undo" do
    test "works" do
      actor = Factory.actor()
      comm = Factory.community(actor)
      coll = Factory.collection(actor, comm)
      resource = Factory.resource(actor, coll)

      actor = Factory.actor()
      assert {:error, :forbidden} = MoodleNet.like_resource(actor, resource)

      MoodleNet.join_community(actor, comm)
      assert {:ok, true} = MoodleNet.like_resource(actor, resource)

      assert {:ok, true} = MoodleNet.undo_like(actor, resource)
      assert {:error, {:not_found, _, "Activity"}} = MoodleNet.undo_like(actor, resource)
    end
  end

  describe "follow_collection & undo" do
    test "works" do
      actor = Factory.actor()
      comm = Factory.community(actor)
      coll = Factory.collection(actor, comm)

      actor = Factory.actor()
      assert {:error, {:not_found, _, "Activity"}} = MoodleNet.undo_follow(actor, coll)
      assert {:ok, true} = MoodleNet.follow_collection(actor, coll)
      assert {:ok, true} = MoodleNet.follow_collection(actor, coll)
      assert {:ok, true} = MoodleNet.undo_follow(actor, coll)
      assert {:error, {:not_found, _, "Activity"}} = MoodleNet.undo_follow(actor, coll)
    end
  end

  test "update_community/2" do
    actor = Factory.actor()
    community = Factory.community(actor)

    assert {:ok, new_community} = MoodleNet.update_community(actor, community, %{name: "NEW NAME"})
    assert new_community.name == %{"und" => "NEW NAME"}

    assert {:ok, new_community} = MoodleNet.update_community(actor, community, %{icon: "new_icon"})
    assert [%{url: ["new_icon"]}] = new_community.icon

    assert {:ok, new_community} = MoodleNet.update_community(actor, community, %{icon: nil})
    assert [] = new_community.icon
  end

  test "update_collection/2" do
    actor = Factory.actor()
    community = Factory.community(actor)
    collection = Factory.collection(actor, community)

    assert {:ok, new_collection} = MoodleNet.update_collection(actor, collection, %{name: "NEW NAME"})
    assert new_collection.name == %{"und" => "NEW NAME"}

    assert {:ok, new_collection} = MoodleNet.update_collection(actor, collection, %{icon: "new_icon"})
    assert [%{url: ["new_icon"]}] = new_collection.icon

    assert {:ok, new_collection} = MoodleNet.update_collection(actor, collection, %{icon: nil})
    assert [] = new_collection.icon
  end

  test "update_resource/2" do
    actor = Factory.actor()
    community = Factory.community(actor)
    collection = Factory.collection(actor, community)
    resource = Factory.resource(actor, collection)

    assert {:ok, new_resource} = MoodleNet.update_resource(actor, resource, %{name: "NEW NAME"})
    assert new_resource.name == %{"und" => "NEW NAME"}

    assert {:ok, new_resource} = MoodleNet.update_resource(actor, resource, %{icon: "new_icon"})
    assert [%{url: ["new_icon"]}] = new_resource.icon

    assert {:ok, new_resource} = MoodleNet.update_resource(actor, resource, %{icon: nil})
    assert [] = new_resource.icon
  end
end
