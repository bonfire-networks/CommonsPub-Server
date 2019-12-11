# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.CommonTest do
  use MoodleNetWeb.ConnCase, async: true
  alias MoodleNet.{Access, Common, Flags, Follows, Likes}
  # import MoodleNet.MediaProxy.URLBuilder, only: [encode: 1]
  import MoodleNetWeb.Test.GraphQLAssertions
  import MoodleNet.Test.Faking
  import MoodleNetWeb.Test.ConnHelpers
  import MoodleNetWeb.Test.GraphQLAssertions
  import MoodleNetWeb.Test.GraphQLFields

  describe "flag" do

    test "does not work for guest" do
      alice = fake_user!()
      bob = fake_user!()
      # alice flags bob. bob is bad.
      {:ok, flag} = Flags.create(alice, bob, %{is_local: true, message: "bad"})
      q = """
      { flag(flagId: "#{flag.id}") {
          #{flag_basics()}
        }
      }
      """
      assert %{"flag" => flag2} = gql_post_data(%{query: q})
      flag2 = assert_flag(flag, flag2)
    end
  end

  describe "follow" do
    test "works for guest" do
      alice = fake_user!()
      bob = fake_user!()
      {:ok, follow} = Follows.create(alice, bob, %{is_local: true}) # alice follows bob
      q = """
      { follow(followId: "#{follow.id}") {
          #{follow_basics()}
        }
      }
      """
      assert %{"follow" => follow2} = gql_post_data(%{query: q})
      follow2 = assert_follow(follow, follow2)
    end
  end
  describe "like" do
    test "works for guest" do
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
  end
  describe "flag.creator" do
    test "works for guest" do
      alice = fake_user!()
      bob = fake_user!()
      # alice flags bob. bob is bad.
      {:ok, flag} = Flags.create(alice, bob, %{is_local: true, message: "bad"})
      q = """
      { flag(flagId: "#{flag.id}") {
          #{flag_basics()}
          creator { #{user_basics()} }
        }
      }
      """
      assert %{"flag" => flag2} = gql_post_data(%{query: q})
      flag2 = assert_flag(flag, flag2)
      assert %{"creator" => creator} = flag2
      assert_user(alice, creator)
    end
  end
  describe "flag.context" do
    test "works for guest on a user" do
      alice = fake_user!()
      bob = fake_user!()
      # alice flags bob. bob is bad.
      {:ok, flag} = Flags.create(alice, bob, %{is_local: true, message: "bad"})
      q = """
      { flag(flagId: "#{flag.id}") {
          #{flag_basics()}
          context { ... on User { #{user_basics()} } }
        }
      }
      """
      assert %{"flag" => flag2} = gql_post_data(%{query: q})
      flag2 = assert_flag(flag, flag2)
      assert %{"context" => context} = flag2
      assert_user(bob, context)
    end
    test "works for guest on a community" do
      alice = fake_user!()
      bob = fake_community!(alice)
      # alice flags bob. bob is bad.
      {:ok, flag} = Flags.create(alice, bob, %{is_local: true, message: "bad"})
      q = """
      { flag(flagId: "#{flag.id}") {
          #{flag_basics()}
          context { ... on Community { #{community_basics()} } }
        }
      }
      """
      assert %{"flag" => flag2} = gql_post_data(%{query: q})
      flag2 = assert_flag(flag, flag2)
      assert %{"context" => context} = flag2
      assert_community(bob, context)
    end
    test "works for guest on a collection" do
      alice = fake_user!()
      bob = fake_community!(alice)
      eve = fake_collection!(alice, bob)
      # alice flags bob. bob is bad.
      {:ok, flag} = Flags.create(alice, eve, %{is_local: true, message: "bad"})
      q = """
      { flag(flagId: "#{flag.id}") {
          #{flag_basics()}
          context { ... on Collection { #{collection_basics()} } }
        }
      }
      """
      assert %{"flag" => flag2} = gql_post_data(%{query: q})
      flag2 = assert_flag(flag, flag2)
      assert %{"context" => context} = flag2
      assert_collection(eve, context)
    end
  end
  describe "follow.creator" do
    test "works for guest" do
      alice = fake_user!()
      bob = fake_user!()
      {:ok, follow} = Follows.create(alice, bob, %{is_local: true}) # alice follows bob
      q = """
      { follow(followId: "#{follow.id}") {
          #{follow_basics()}
          creator { #{user_basics()} }
        }
      }
      """
      assert %{"follow" => follow2} = gql_post_data(%{query: q})
      follow2 = assert_follow(follow, follow2)
      assert %{"creator" => creator} = follow2
      assert_user(alice, creator)
    end
  end
  describe "follow.context" do
    test "works for guest with a user follow" do
      alice = fake_user!()
      bob = fake_user!()
      {:ok, follow} = Follows.create(alice, bob, %{is_local: true}) # alice follows bob
      q = """
      { follow(followId: "#{follow.id}") {
          #{follow_basics()}
          context { ... on User { #{user_basics()} } }
        }
      }
      """
      assert %{"follow" => follow2} = gql_post_data(%{query: q})
      follow2 = assert_follow(follow, follow2)
      assert %{"context" => context} = follow2
      assert_user(bob, context)
    end
    test "works for guest with a community follow" do
      alice = fake_user!()
      bob = fake_community!(alice)
      {:ok, follow} = Follows.create(alice, bob, %{is_local: true}) # alice follows bob
      q = """
      { follow(followId: "#{follow.id}") {
          #{follow_basics()}
          context { ... on Community { #{community_basics()} } }
        }
      }
      """
      assert %{"follow" => follow2} = gql_post_data(%{query: q})
      follow2 = assert_follow(follow, follow2)
      assert %{"context" => context} = follow2
      assert_community(bob, context)
    end
    test "works for guest with a collection follow" do
      alice = fake_user!()
      bob = fake_community!(alice)
      eve = fake_collection!(alice, bob)
      {:ok, follow} = Follows.create(alice, eve, %{is_local: true}) # alice follows bob
      q = """
      { follow(followId: "#{follow.id}") {
          #{follow_basics()}
          context { ... on Collection { #{collection_basics()} } }
        }
      }
      """
      assert %{"follow" => follow2} = gql_post_data(%{query: q})
      follow2 = assert_follow(follow, follow2)
      assert %{"context" => context} = follow2
      assert_collection(eve, context)
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
      {:ok, _} = Common.find_like(alice, bob)
    end
  end

  describe "createFollow" do
    test "works for a user following a user" do
      alice = fake_user!()
      bob = fake_user!()
      conn = user_conn(alice)
      q = """
      mutation Test {
        createFollow(contextId: "#{bob.id}") {
          #{follow_basics()}
        }
      }
      """
      query = %{query: q, mutation: "Test"}
      assert %{"createFollow" => follow} = gql_post_data(conn, query)
      assert_follow(follow)
      {:ok, _} = Common.find_follow(alice, bob)
    end
  end
  # describe "tags" do
  # end

  # describe "create_tagging" do
  #   test "works" do
  #     vars = %{"contextId" => "", "tagId" => ""}
  #     query = %{operationName: "Test", query: @create_tagging_q, variables: vars}
  #     assert %{"tag" => tagging} = gql_post_data(json_conn(),query)
  #     assert_tagging(tagging)
  #   end
  # end

  # defp assert_already_liked(errs, path) do
  #   assert [err] = errs
  #   assert %{"code" => code, "message" => message} = err
  #   assert %{"path" => ^path, "locations" => [loc]} = err
  #   assert code == "already_liked"
  #   assert message == "already liked"
  #   assert_location(loc)
  # end

  # defp assert_already_following(errs, path) do
  #   assert [err] = errs
  #   assert %{"code" => code, "message" => message} = err
  #   assert %{"path" => ^path, "locations" => [loc]} = err
  #   assert code == "already_following"
  #   assert message == "already following"
  #   assert_location(loc)
  # end

  # defp assert_already_flagged(errs, path) do
  #   assert [err] = errs
  #   assert %{"code" => code, "message" => message} = err
  #   assert %{"path" => ^path, "locations" => [loc]} = err
  #   assert code == "already_flagged"
  #   assert message == "already flagged"
  #   assert_location(loc)
  # end

end
