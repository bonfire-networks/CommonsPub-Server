# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
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
      [alice, bob] = some_fake_users!(2)
      {:ok, follow} = Follows.create(alice, bob, %{is_local: true}) # alice follows bob
      q = follow_query()
      conn = json_conn()
      follow2 = gruff_post_key(q, conn, :follow, %{follow_id: follow.id})
      assert_follow(follow, follow2)
    end

    test "works for guest for a public follow of a community" do
      alice = fake_user!()
      bob = fake_community!(alice, %{is_local: true})
      {:ok, follow} = Follows.one(creator_id: alice.id, context_id: bob.id)
      q = follow_query()
      conn = json_conn()
      follow2 = gruff_post_key(q, conn, :follow, %{follow_id: follow.id})
      assert_follow(follow, follow2)
    end

    test "works for guest for a public follow of a collection" do
      alice = fake_user!()
      bob = fake_community!(alice, %{is_local: true})
      _celia = fake_collection!(alice, bob, %{is_local: true})
      {:ok, follow} = Follows.one(creator_id: alice.id, context_id: bob.id)
      q = follow_query()
      conn = json_conn()
      follow2 = gruff_post_key(q, conn, :follow, %{follow_id: follow.id})
      assert_follow(follow, follow2)
    end

  end

  describe "follow.creator" do
    test "works for guest" do
      alice = fake_user!()
      bob = fake_user!()
      {:ok, follow} = Follows.create(alice, bob, %{is_local: true}) # alice follows bob
      q = follow_query(fields: [creator: user_fields()])
      conn = json_conn()
      follow2 = assert_follow(follow, gruff_post_key(q, conn, :follow, %{follow_id: follow.id}))
      assert %{"creator" => creator} = follow2
      assert_user(alice, creator)
    end
  end

  describe "follow.context" do
    test "works for guest with a user follow" do
      alice = fake_user!()
      bob = fake_user!()
      follow = follow!(alice, bob)
      q = follow_query(fields: [context: [user_spread()]])
      conn = json_conn()
      follow2 = assert_follow(follow, gruff_post_key(q, conn, :follow, %{follow_id: follow.id}))
      assert %{"context" => context} = follow2
      assert_user(bob, context)
    end

    test "works for guest with a community follow" do
      alice = fake_user!()
      bob = fake_community!(alice)
      q = follow_query(fields: [context: [community_spread()]])
      conn = json_conn()
      {:ok, follow} = Follows.one(creator_id: alice.id, context_id: bob.id)
      follow2 = assert_follow(follow, gruff_post_key(q, conn, :follow, %{follow_id: follow.id}))
      assert %{"context" => context} = follow2
      assert_community(bob, context)
    end

    test "works for guest with a collection follow" do
      alice = fake_user!()
      bob = fake_community!(alice)
      eve = fake_collection!(alice, bob)
      q = follow_query(fields: [context: [collection_spread()]])
      conn = json_conn()
      {:ok, follow} = Follows.one(creator_id: alice.id, context_id: eve.id)
      follow2 = assert_follow(follow, gruff_post_key(q, conn, :follow, %{follow_id: follow.id}))
      assert %{"context" => context} = follow2
      assert_collection(eve, context)
    end
  end

  describe "createFollow" do
    test "works for a user following a user" do
      [alice, bob] = some_fake_users!(2)
      conn = user_conn(alice)
      q = create_follow_mutation()
      follow2 = assert_follow(gruff_post_key(q, conn, :create_follow, %{context_id: bob.id}))
      {:ok, follow} = Follows.one(creator_id: alice.id, context_id: bob.id)
      assert_follow(follow, follow2)
    end

    @remote_actor "https://kawen.space/users/karen"
    @tag :skip # bizarre error possibly related to cachex
    test "works for a user following a remote user" do
      actor = fake_user!()
      conn = user_conn(actor)
      q = follow_remote_actor_mutation()
      vars = %{url: @remote_actor}
      follow2 = gruff_post_key(q, conn, :follow_remote_actor, vars)
      {:ok, followed} = MoodleNet.ActivityPub.Adapter.get_actor_by_ap_id(@remote_actor)
      {:ok, follow} = Follows.one(creator_id: actor.id, context_id: followed.id)
      assert_follow(follow, follow2)
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
