# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.UsersTest do
  use MoodleNetWeb.ConnCase, async: true
  import MoodleNetWeb.Test.Automaton
  import MoodleNetWeb.Test.GraphQLAssertions
  import MoodleNetWeb.Test.GraphQLFields
  import MoodleNet.Test.Trendy
  import MoodleNet.Test.Faking
  import Grumble
  import Zest
  alias MoodleNet.Test.Fake

  describe "username_available" do

    test "works for a guest or a user" do
      alice = fake_user!()
      q = username_available_query()
      for conn <- [json_conn(), user_conn(alice)] do
        vars = %{username: Fake.preferred_username()}
        assert true == grumble_post_key(q, conn, :username_available, vars)
        vars = %{username: alice.actor.preferred_username}
        assert false == grumble_post_key(q, conn, :username_available, vars)
      end
    end

  end

  describe "me" do

    test "works for a logged in user" do
      alice = fake_user!()
      q = me_query()
      me = grumble_post_key(q, user_conn(alice), :me)
      assert_me(alice, me)
    end

    test "does not work for a guest" do
      assert_not_logged_in(grumble_post_errors(me_query(), json_conn()), ["me"])
    end

  end

  describe "user" do

    test "Works for anyone with a public user" do
      alice = fake_user!()
      lucy = fake_admin!()
      q = user_query()
      for conn <- [json_conn(), user_conn(alice), user_conn(lucy)] do
        user = grumble_post_key(q, conn, :user, %{user_id: alice.id})
        assert_user(alice, user)
      end
    end

  end

  describe "user.last_activity" do

    @tag :skip
    test "placeholder" do
    end

  end

  describe "user.my_follow" do

    test "is nil for a guest or a non-following user or instance admin" do
      [alice, bob] = some_fake_users!(%{}, 2)
      lucy = fake_user!(%{is_instance_admin: true})
      vars = %{user_id: bob.id}
      q = user_query(fields: [my_follow: follow_fields()])
      for conn <- [json_conn(), user_conn(alice), user_conn(lucy)] do
        user = assert_user(bob, grumble_post_key(q, conn, :user, vars))
        assert user.my_follow == nil
      end
    end

    test "works for a following user or instance admin" do
      [alice, bob] = some_fake_users!(%{}, 2)
      lucy = fake_user!(%{is_instance_admin: true})
      vars = %{user_id: bob.id}
      q = user_query(fields: [my_follow: follow_fields()])
      for user <- [alice, lucy] do
        follow = follow!(user, bob)
        user2 = assert_user(bob, grumble_post_key(q, user_conn(user), :user, vars))
        assert_follow(follow, user2.my_follow)
      end
    end

  end

  describe "user.my_like" do

    test "is nil for a guest or a non-liking user or instance admin" do
      [alice, bob] = some_fake_users!(%{}, 2)
      lucy = fake_user!(%{is_instance_admin: true})
      vars = %{user_id: bob.id}
      q = user_query(fields: [my_like: like_fields()])
      for conn <- [json_conn(), user_conn(alice), user_conn(lucy)] do
        user = assert_user(bob, grumble_post_key(q, conn, :user, vars))
        assert user.my_like == nil
      end
    end

    test "works for a liking user or instance admin" do
      [alice, bob] = some_fake_users!(%{}, 2)
      lucy = fake_user!(%{is_instance_admin: true})
      vars = %{user_id: bob.id}
      q = user_query(fields: [my_like: like_fields()])
      for user <- [alice, lucy] do
        like = like!(user, bob)
        user2 = assert_user(bob, grumble_post_key(q, user_conn(user), :user, vars))
        assert_like(like, user2.my_like)
      end
    end

  end

  describe "user.followed_communities" do

    test "works for anyone" do
      [alice, bob, eve] = some_fake_users!(%{}, 3)
      lucy = fake_user!(%{is_instance_admin: true})
      comm = fake_community!(alice)
      comm2 = fake_community!(bob)
      follows = Enum.map([comm, comm2], &follow!(eve, &1))
      q = user_query(fields: [followed_communities: page_fields(followed_community_fields())])
      vars = %{user_id: eve.id}
      conns = [user_conn(alice), user_conn(bob), user_conn(lucy), user_conn(eve), json_conn()]
      for conn <- conns do
        user = assert_user(eve, grumble_post_key(q, conn, :user, vars))
        follows2 = assert_page(user.followed_communities, 2, 2, false, false, &[&1.id])
        each(follows, follows2, &assert_follow/2)
      end
    end

  end

  describe "user.followed_collections" do

    test "works for anyone" do
      [alice, bob, eve] = some_fake_users!(%{}, 3)
      lucy = fake_user!(%{is_instance_admin: true})
      comm = fake_community!(alice)
      coll = fake_collection!(alice, comm)
      coll2 = fake_collection!(bob, comm)
      follows = Enum.map([coll, coll2], &follow!(eve, &1))
      q = user_query(fields: [followed_collections: page_fields(followed_collection_fields())])
      vars = %{user_id: eve.id}
      conns = [user_conn(alice), user_conn(bob), user_conn(lucy), user_conn(eve), json_conn()]
      for conn <- conns do
        user = assert_user(eve, grumble_post_key(q, conn, :user, vars))
        follows2 = assert_page(user.followed_collections, 2, 2, false, false, &[&1.id])
        each(follows, follows2, &assert_follow/2)
      end
    end

  end

  describe "user.followed_users" do
    @tag :skip
    test "placeholder" do
    end
  end

  describe "user.likers" do

    test "works for anyone for a public user" do
      [alice, bob] = some_fake_users!(2)
      lucy = fake_admin!()
      likes = some_randomer_likes!(27, alice)
      params = [
        likers_after: list_type(:cursor),
        likers_before: list_type(:cursor),
        likers_limit: :int,
      ]
      query = user_query(fields: [:liker_count, likers_subquery()], params: params)
      conns = pam([alice, bob, lucy], &user_conn/1)
      each [json_conn() | conns], fn conn ->
        child_page_test %{
          query: query,
          vars: %{user_id: alice.id},
          connection: conn,
          parent_key: :user,
          child_key: :likers,
          count_key: :liker_count,
          default_limit: 10,
          total_count: 27,
          parent_data: alice,
          child_data: likes,
          assert_parent: &assert_user/2,
          assert_child: &assert_like/2,
          cursor_fn: &[&1.id],
          after: :likers_after,
          before: :likers_before,
          limit: :likers_limit,
        }
      end
    end

  end

  describe "user.likes" do

    test "works for anyone for a public user" do
      [alice, bob, dave, eve] = some_fake_users!(4)
      lucy = fake_user!(%{is_instance_admin: true})
      comms = some_fake_communities!(9, [bob])
      colls = some_fake_collections!(2, [dave], comms) #
      likes = pam(colls ++ comms, &like!(alice, &1))
      params = [
        likes_after: list_type(:cursor),
        likes_before: list_type(:cursor),
        likes_limit: :int,
      ]
      query = user_query(fields: [:like_count, likes_subquery()], params: params)
      conns = [user_conn(alice), user_conn(bob), user_conn(lucy), user_conn(eve), json_conn()]
      each conns, fn conn ->
        child_page_test %{
          query: query,
          vars: %{user_id: alice.id},
          connection: conn,
          parent_key: :user,
          child_key: :likes,
          count_key: :like_count,
          default_limit: 10,
          total_count: 27,
          parent_data: alice,
          child_data: likes,
          assert_parent: &assert_user/2,
          assert_child: &assert_like/2,
          cursor_fn: &[&1.id],
          after: :likes_after,
          before: :likes_before,
          limit: :likes_limit,
        }
      end
    end

  end

  # describe "comments" do
  #   @tag :skip
  #   test "placeholder" do
  #   end
  # end

  # describe "inbox" do
  #   @tag :skip # broken
  #   test "Works for self" do
  #     alice = fake_user!()
  #     bob = fake_user!()
  #     comm = fake_community!(bob)
  #     conn = user_conn(alice)
  #     query = """
  #     { me {
  #         #{me_basics()}
  #         user {
  #           #{user_basics()}
  #           inbox { #{page_basics()} edges { #{activity_basics()} }
  #         }
  #       }
  #     }
  #     """
  #     assert %{"me" => me} = gql_post_data(conn, %{query: query})
  #     me = assert_me(me)
  #     assert %{"user" => user2} = me
  #     user2 = assert_user(alice, user2)
  #     assert %{"inbox" => inbox} = user2
  #     edges = assert_edges_page(inbox)
  #     assert Enum.count(edges.edges) == 1
  #     for edge <- edges.edges do
  #       activity = assert_activity(edge)
  #     end
  #   end
  #   # test "Does not work for other" do
  #   # end
  #   # test "Does not work for guest" do
  #   # end
  # end

  # describe "outbox" do

  #   test "Works for self" do
  #     user = fake_user!()
  #     conn = user_conn(user)
  #     query = """
  #     { me {
  #         #{me_basics()}
  #         user {
  #           #{user_basics()}
  #           outbox { #{page_basics()} edges { #{activity_basics()} } }
  #         }
  #       }
  #     }
  #     """
  #     assert %{"me" => me} = gql_post_data(conn, %{query: query})
  #     me = assert_me(me)
  #     assert %{"user" => user2} = me
  #     user2 = assert_user(user, user2)
  #     assert %{"outbox" => outbox} = user2
  #     edges = assert_edges_page(outbox)
  #     # assert Enum.count(edges.edges) == 5
  #     for edge <- edges.edges do
  #       activity = assert_activity(edge)
  #     end
  #   end
  # end

end
