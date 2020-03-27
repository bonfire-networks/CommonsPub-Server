# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.Collections.CollectionTest do
  use MoodleNetWeb.ConnCase, async: true
  import MoodleNetWeb.Test.GraphQLAssertions
  import MoodleNetWeb.Test.GraphQLFields
  import MoodleNet.Test.Trendy
  import MoodleNet.Test.Faking
  alias MoodleNet.{Flags, Follows, Likes}

  describe "collection" do

    test "works for the owner, randoms, admins and guests" do
      [alice, bob] = some_fake_users!(%{}, 2)
      lucy = fake_user!(%{is_instance_admin: true})
      comm = fake_community!(alice)
      coll = fake_collection!(alice, comm)
      conns = [user_conn(alice), user_conn(bob), user_conn(lucy), json_conn()]
      vars = %{"collectionId" => coll.id}
      for conn <- conns do
        coll2 = gruff_post_key(collection_query(), conn, "collection", vars)
        assert_collection(coll, coll2)
      end
    end

  end

  describe "collection.last_activity" do
    @tag :skip
    test "placeholder" do
    end
  end

  describe "collection.my_like" do

    test "is nil for a guest or a non-liking user or instance admin" do
      [alice, bob] = some_fake_users!(%{}, 2)
      lucy = fake_user!(%{is_instance_admin: true})
      comm = fake_community!(alice)
      coll = fake_collection!(bob, comm)
      vars = %{"collectionId" => coll.id}
      q = collection_query(fields: [my_like: like_fields()])
      for conn <- [json_conn(), user_conn(alice), user_conn(bob), user_conn(lucy)] do
        coll2 = gruff_post_key(q, conn, "collection", vars)
        coll2 = assert_collection(coll, coll2)
        assert coll2["myLike"] == nil
      end
    end

    test "works for a liking user or instance admin" do
      [alice, bob] = some_fake_users!(%{}, 2)
      lucy = fake_user!(%{is_instance_admin: true})
      comm = fake_community!(alice)
      coll = fake_collection!(bob, comm)
      vars = %{"collectionId" => coll.id}
      q = collection_query(fields: [my_like: like_fields()])
      for user <- [alice, bob, lucy] do
        {:ok, like} = Likes.create(user, coll, %{is_local: true})
        coll2 = gruff_post_key(q, user_conn(user), "collection", vars)
        coll2 = assert_collection(coll, coll2)
        assert_like(like, coll2["myLike"])
      end
    end

  end

  describe "collection.my_follow" do

    test "is nil for a guest or a non-following user or instance admin" do
      [alice, bob] = some_fake_users!(%{}, 2)
      lucy = fake_user!(%{is_instance_admin: true})
      comm = fake_community!(alice)
      coll = fake_collection!(bob, comm)
      vars = %{"collectionId" => coll.id}
      q = collection_query(fields: [my_follow: follow_fields()])
      for conn <- [json_conn(), user_conn(alice), user_conn(lucy)] do
        coll2 = gruff_post_key(q, conn, "collection", vars)
        coll2 = assert_collection(coll, coll2)
        assert coll2["myFollow"] == nil
      end
    end

    test "works for a following user or instance admin" do
      [alice, bob] = some_fake_users!(%{}, 2)
      lucy = fake_user!(%{is_instance_admin: true})
      comm = fake_community!(alice)
      coll = fake_collection!(bob, comm)
      vars = %{collection_id: coll.id}
      q = collection_query(fields: [my_follow: follow_fields()])
      coll2 = gruff_post_key(q, user_conn(bob), :collection, vars)
      coll2 = assert_collection(coll, coll2)
      assert_follow(coll2["myFollow"])

      for user <- [alice, lucy] do
        {:ok, follow} = Follows.create(user, coll, %{is_local: true})
        coll2 = gruff_post_key(q, user_conn(user), :collection, vars)
        coll2 = assert_collection(coll, coll2)
        assert_follow(follow, coll2["myFollow"])
      end
    end

  end

  describe "collection.my_flag" do

    test "is nil for a guest or a non-flagging user or instance admin" do
      [alice, bob] = some_fake_users!(%{}, 2)
      lucy = fake_user!(%{is_instance_admin: true})
      comm = fake_community!(alice)
      coll = fake_collection!(bob, comm)
      vars = %{"collectionId" => coll.id}
      q = collection_query(fields: [my_flag: flag_fields()])
      for conn <- [json_conn(), user_conn(alice), user_conn(bob), user_conn(lucy)] do
        coll2 = gruff_post_key(q, conn, "collection", vars)
        coll2 = assert_collection(coll, coll2)
        assert coll2["myFlag"] == nil
      end
    end

     test "works for a flagging user or instance admin" do
      [alice, bob] = some_fake_users!(%{}, 2)
      lucy = fake_user!(%{is_instance_admin: true})
      comm = fake_community!(alice)
      coll = fake_collection!(bob, comm)
      vars = %{"collectionId" => coll.id}
      q = collection_query(fields: [my_flag: flag_fields()])
      for user <- [alice, bob, lucy] do
        {:ok, flag} = Flags.create(user, coll, %{is_local: true, message: "bad"})
        coll2 = gruff_post_key(q, user_conn(user), "collection", vars)
        coll2 = assert_collection(coll, coll2)
        assert_flag(flag, coll2["myFlag"])
      end
    end

  end

  describe "collection.creator" do
    @tag :skip
    test "placeholder" do
    end
  end

  describe "collection.community" do

    test "works for anyone" do
      [alice, bob, eve] = some_fake_users!(%{}, 3)
      lucy = fake_user!(%{is_instance_admin: true})
      comm = fake_community!(alice)
      coll = fake_collection!(bob, comm)
      vars = %{"collectionId" => coll.id}
      q = collection_query(fields: [community: community_fields()])
      conns = [user_conn(alice), user_conn(bob), user_conn(lucy), user_conn(eve), json_conn()]
      for conn <- conns do
        coll2 = gruff_post_key(q, conn, "collection", vars)
        assert_community(comm, coll2["community"])
      end
    end

  end

  describe "collection.resources" do

    test "works for anyone for a public collection" do
      [alice, bob, eve] = some_fake_users!(%{}, 3)
      lucy = fake_user!(%{is_instance_admin: true})
      comm = fake_community!(alice)
      coll = fake_collection!(bob, comm)
      res = Enum.reverse(Enum.map(1..5, fn _ -> fake_resource!(alice, coll) end)) 
      q = collection_query(fields: [:resource_count, resources: page_fields(resource_fields())])
      vars = %{collection_id: coll.id}
      conns = [user_conn(alice), user_conn(bob), user_conn(lucy), user_conn(eve), json_conn()]
      for conn <- conns do
        coll2 = assert_collection(coll, gruff_post_key(q, conn, "collection", vars))
        assert %{"resources" => res2, "resourceCount" => count} = coll2
        assert count == 5
        edges = assert_page(res2, 5, 5, false, false, &(&1["id"]))
        for {re, re2} <- Enum.zip(res, edges.edges) do
          assert_resource(re, re2)
        end
      end
    end

  end

  describe "collection.followers" do

    test "works for anyone for a public collection" do
      [alice, bob, eve] = some_fake_users!(%{}, 3)
      lucy = fake_user!(%{is_instance_admin: true})
      comm = fake_community!(alice)
      coll = fake_collection!(bob, comm)
      some_randomer_follows!(23, coll)
      q = collection_query(fields: [:follower_count, followers: page_fields(follow_fields())])
      vars = %{"collectionId" => coll.id}
      conns = [user_conn(alice), user_conn(bob), user_conn(eve), user_conn(lucy), json_conn()]
      for conn <- conns do
        coll2 = assert_collection(coll, gruff_post_key(q, conn, "collection", vars))
        assert %{"followers" => follows, "followerCount" => count} = coll2
        assert count == 24 # 23 + creator
        edges = assert_page(follows, 10, 24, false, true, &(&1["id"]))
        for edge <- edges.edges, do: assert_follow(edge)
      end
    end

  end

  describe "collection.likers" do

    test "works for anyone for a public collection" do
      [alice, bob, eve] = some_fake_users!(%{}, 3)
      lucy = fake_user!(%{is_instance_admin: true})
      comm = fake_community!(alice)
      coll = fake_collection!(bob, comm)
      some_randomer_likes!(23, coll)
      q = collection_query(fields: [:liker_count, likers: page_fields(like_fields())])
      vars = %{"collectionId" => coll.id}
      conns = [user_conn(alice), user_conn(bob), user_conn(lucy), user_conn(eve), json_conn()]
      for conn <- conns do
        coll2 = gruff_post_key(q, conn, "collection", vars)
        coll2 = assert_collection(coll, coll2)
        assert %{"likers" => likes, "likerCount" => count} = coll2
        assert count == 23
        likes = assert_page(likes, 10, 23, false, true, &(&1["id"]))
        for edge <- likes.edges, do: assert_like(edge)
      end
    end

  end

  describe "collection.flags" do

    test "empty for a guest or non-flagging user" do
      [alice, bob, eve, mallory] = some_fake_users!(%{}, 4)
      lucy = fake_user!(%{is_instance_admin: true})
      comm = fake_community!(alice)
      coll = fake_collection!(bob, comm)
      {:ok, _} = Flags.create(eve, coll, %{is_local: true, message: "bad"})
      {:ok, _} = Flags.create(lucy, coll, %{is_local: true, message: "bad"})
      q = collection_query(fields: [flags: page_fields(flag_fields())])
      vars = %{"collectionId" => coll.id}
      conns = [user_conn(mallory), json_conn()]
      for conn <- conns do
        coll2 = gruff_post_key(q, conn, "collection", vars)
        coll2 = assert_collection(coll, coll2)
        assert %{"flags" => flags} = coll2
        assert_page(flags, 0, 0, false, false, &(&1["id"]))
      end
    end

    # TODO: alice and bob should also see 2
    test "not empty for a flagging user, collection owner, community owner or admin" do
      [alice, bob, eve] = some_fake_users!(%{}, 3)
      lucy = fake_user!(%{is_instance_admin: true})
      comm = fake_community!(alice)
      coll = fake_collection!(bob, comm)
      {:ok, _} = Flags.create(eve, coll, %{is_local: true, message: "bad"})
      {:ok, _} = Flags.create(lucy, coll, %{is_local: true, message: "bad"})
      q = collection_query(fields: [flags: page_fields(flag_fields())])
      vars = %{"collectionId" => coll.id}

      coll2 = assert_collection(gruff_post_key(q, user_conn(eve), "collection", vars))
      assert %{"flags" => flags} = coll2
      edges = assert_page(flags, 1, 1, false, false, &(&1["id"]))
      for edge <- edges.edges, do: assert_flag(edge)

      for conn <- [user_conn(lucy)] do
        coll2 = assert_collection(gruff_post_key(q, conn, "collection", vars))
        assert %{"flags" => flags} = coll2
        edges = assert_page(flags, 2, 2, false, false, &(&1["id"]))
        for edge <- edges.edges, do: assert_flag(edge)
      end
    end

  end

  describe "collection.threads" do

    test "works for anyone when there are no threads" do
      [alice, bob, eve] = some_fake_users!(3)
      lucy = fake_admin!()
      comm = fake_community!(alice)
      coll = fake_collection!(bob, comm)
      q = collection_query(fields: [threads_subquery(fields: [comments_subquery()])])
      vars = %{"collectionId" => coll.id}
      for conn <- [json_conn(), user_conn(eve), user_conn(bob), user_conn(alice), user_conn(lucy)] do
        coll2 = assert_collection(coll, gruff_post_key(q, conn, "collection", vars))
        assert %{"threads" => threads} = coll2
        assert_page(threads, 0, 0, false, false, &(&1.id))
      end
    end

    test "works for anyone when there are threads" do
      [alice, bob] = some_fake_users!(2)
      lucy = fake_admin!()
      comm = fake_community!(alice)
      coll = fake_collection!(bob, comm)
      randomers = some_fake_users!(5)
      many_randomers = repeat_for_count(randomers, 25)
      threads_and_initials = flat_pam_some(randomers, 5, fn user -> # 25
        thread = fake_thread!(user, coll)
        comment = fake_comment!(user, thread)
        {thread, comment}
      end)
      threads_and_replies =
        zip(many_randomers, threads_and_initials, fn user, {thread, initial} ->
          reply = fake_reply!(user, thread, initial)
          {thread, reply}
        end)
      # final_replies =
      _ =  zip(many_randomers, threads_and_replies, fn user, {thread, comment} ->
          fake_reply!(user, thread, comment)
        end)
      {_threads, _initials} = unpiz(threads_and_initials)
      # replies = Enum.map(threads_and_replies, &elem(&1, 1))
      # comments = final_replies ++ replies ++ initials
      q = collection_query(fields: [threads_subquery(fields: [comments_subquery(args: [limit: 1])])])
      vars = %{"collectionId" => coll.id}
      for conn <- [json_conn(), user_conn(bob), user_conn(alice), user_conn(lucy)] do
        coll2 = assert_collection(coll, gruff_post_key(q, conn, "collection", vars))
        assert %{"threads" => threads} = coll2
        _threads = assert_page(threads, 10, 25, false, true, &(&1["id"]))
        # initials2 = Enum.flat_map(threads.edges, fn thread ->
        #   assert_page(thread["comments"], 1, 3, nil, true, &(&1["id"])).edges
        # end)
        # assert Enum.count(initials2) == 10
        # each(Enum.reverse(initials), initials2, &assert_comment/2)
      end
    end

  end

  describe "collection.outbox" do
    @tag :skip
    test "placeholder" do
    end
  end

end
