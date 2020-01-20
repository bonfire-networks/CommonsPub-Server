# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.LikesTest do
  use MoodleNetWeb.ConnCase, async: true
  alias MoodleNet.Likes
  # import MoodleNet.MediaProxy.URLBuilder, only: [encode: 1]
  import MoodleNet.Test.Faking
  import MoodleNetWeb.Test.ConnHelpers
  import MoodleNetWeb.Test.GraphQLAssertions
  import MoodleNetWeb.Test.GraphQLFields

  describe "like" do
    test "works for guest for a like of a user" do
      alice = fake_user!()
      bob = fake_user!()
      {:ok, like} = Likes.create(alice, bob, %{is_local: true}) # alice likes bob
      q = """
      { like(likeId: "#{like.id}") {
          #{like_basics()}
        }
      }
      """
      assert %{"like" => like2} = gql_post_data(%{query: q})
      like2 = assert_like(like, like2)
    end
    test "works for guest for a like of a community" do
      alice = fake_user!()
      bob = fake_community!(alice)
      {:ok, like} = Likes.create(alice, bob, %{is_local: true}) # alice likes bob
      q = """
      { like(likeId: "#{like.id}") {
          #{like_basics()}
        }
      }
      """
      assert %{"like" => like2} = gql_post_data(%{query: q})
      like2 = assert_like(like, like2)
    end
    test "works for guest for a like of a collection" do
      alice = fake_user!()
      bob = fake_community!(alice)
      celia = fake_collection!(alice, bob, %{is_local: true})
      {:ok, like} = Likes.create(alice, celia, %{is_local: true}) # alice likes bob
      q = """
      { like(likeId: "#{like.id}") {
          #{like_basics()}
        }
      }
      """
      assert %{"like" => like2} = gql_post_data(%{query: q})
      like2 = assert_like(like, like2)
    end
  end

  describe "like.creator" do
    test "works for guest" do
      alice = fake_user!()
      bob = fake_user!()
      {:ok, like} = Likes.create(alice, bob, %{is_local: true}) # alice likes bob
      q = """
      { like(likeId: "#{like.id}") {
          #{like_basics()}
          creator { #{user_basics()} }
        }
      }
      """
      assert %{"like" => like2} = gql_post_data(%{query: q})
      like2 = assert_like(like, like2)
      assert %{"creator" => creator} = like2
      assert_user(alice, creator)
    end
  end
  describe "like.context" do
    test "works for guest with a user like" do
      alice = fake_user!()
      bob = fake_user!()
      {:ok, like} = Likes.create(alice, bob, %{is_local: true}) # alice likes bob
      q = """
      { like(likeId: "#{like.id}") {
          #{like_basics()}
          context { ... on User { #{user_basics()} } }
        }
      }
      """
      assert %{"like" => like2} = gql_post_data(%{query: q})
      like2 = assert_like(like, like2)
      assert %{"context" => context} = like2
      assert_user(bob, context)
    end
    @tag :skip # community likes are blocked at present
    test "works for guest with a community like" do
      alice = fake_user!()
      bob = fake_community!(alice)
      {:ok, like} = Likes.create(alice, bob, %{is_local: true}) # alice likes bob
      q = """
      { like(likeId: "#{like.id}") {
          #{like_basics()}
          context { ... on Community { #{community_basics()} } }
        }
      }
      """
      assert %{"like" => like2} = gql_post_data(%{query: q})
      like2 = assert_like(like, like2)
      assert %{"context" => context} = like2
      assert_community(bob, context)
    end
    test "works for guest with a collection like" do
      alice = fake_user!()
      bob = fake_community!(alice)
      eve = fake_collection!(alice, bob)
      {:ok, like} = Likes.create(alice, eve, %{is_local: true}) # alice likes bob
      q = """
      { like(likeId: "#{like.id}") {
          #{like_basics()}
          context { ... on Collection { #{collection_basics()} } }
        }
      }
      """
      assert %{"like" => like2} = gql_post_data(%{query: q})
      like2 = assert_like(like, like2)
      assert %{"context" => context} = like2
      assert_collection(eve, context)
    end
  end

  describe "createLike" do
    test "works for a user liking a user" do
      alice = fake_user!()
      bob = fake_user!()
      conn = user_conn(alice)
      q = """
      mutation Test {
        createLike(contextId: "#{bob.id}") {
          #{like_basics()}
        }
      }
      """
      query = %{query: q, mutation: "Test"}
      assert %{"createLike" => like} = gql_post_data(conn, query)
      assert_like(like)
      {:ok, _} = Likes.one(creator_id: alice.id, context_id: bob.id)
    end
  end

end
