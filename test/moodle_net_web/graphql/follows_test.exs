# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.FollowsTest do
  use MoodleNetWeb.ConnCase
  alias MoodleNet.Follows
  # import MoodleNet.MediaProxy.URLBuilder, only: [encode: 1]
  import MoodleNet.Test.Faking
  import MoodleNetWeb.Test.ConnHelpers
  import MoodleNetWeb.Test.GraphQLAssertions
  import MoodleNetWeb.Test.GraphQLFields
  import Tesla.Mock

  setup do
    mock(fn
      env ->
        apply(HttpRequestMock, :request, [env])
    end)

    :ok
  end

  describe "follow" do
    test "works for guest for a public follow of a user" do
      alice = fake_user!()
      bob = fake_user!()
      {:ok, follow} = Follows.create(alice, bob, %{is_local: true}) # alice follows bob
      q = """
      { follow(followId: "#{follow.id}") {
          #{follow_basics()}
        }
      }
      """
      assert %{"follow" => follow} = gql_post_data(%{query: q})
      assert_follow(follow)
    end

    test "works for guest for a public follow of a community" do
      alice = fake_user!()
      bob = fake_community!(alice, %{is_local: true})
      {:ok, follow} = Follows.one(creator_id: alice.id, context_id: bob.id)
      q = """
      { follow(followId: "#{follow.id}") {
          #{follow_basics()}
        }
      }
      """
      assert %{"follow" => follow2} = gql_post_data(%{query: q})
      assert_follow(follow, follow2)
    end

    test "works for guest for a public follow of a collection" do
      alice = fake_user!()
      bob = fake_community!(alice, %{is_local: true})
      celia = fake_collection!(alice, bob, %{is_local: true})
      {:ok, follow} = Follows.one(creator_id: alice.id, context_id: bob.id)
      q = """
      { follow(followId: "#{follow.id}") {
          #{follow_basics()}
        }
      }
      """
      assert %{"follow" => follow2} = gql_post_data(%{query: q})
      assert_follow(follow, follow2)
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
      {:ok, follow} = Follows.one(creator_id: alice.id, context_id: bob.id)
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
      {:ok, follow} = Follows.one(creator_id: alice.id, context_id: eve.id)
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
      {:ok, _} = Follows.one(creator_id: alice.id, context_id: bob.id)
    end

    test "works for a user following a remote user" do
      actor = fake_user!()
      conn = user_conn(actor)
      q = """
      mutation Test {
        createFollowByURL(url: "https://kawen.space/users/karen") {
          #{follow_basics()}
        }
      }
    """
    query = %{query: q, mutation: "Test"}
    assert %{"createFollowByURL" => follow} = gql_post_data(conn, query)
    assert_follow(follow)
    {:ok, followed} = MoodleNet.ActivityPub.Adapter.get_actor_by_ap_id("https://kawen.space/users/karen")
    {:ok, _} = Follows.one(creator_id: actor.id, context_id: followed.id)
    end
  end

  # defp assert_already_following(errs, path) do
  #   assert [err] = errs
  #   assert %{"code" => code, "message" => message} = err
  #   assert %{"path" => ^path, "locations" => [loc]} = err
  #   assert code == "already_following"
  #   assert message == "already following"
  #   assert_location(loc)
  # end

end
