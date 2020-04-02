# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.ResourceTest do
  use MoodleNetWeb.ConnCase, async: true
  import MoodleNetWeb.Test.GraphQLAssertions
  import MoodleNetWeb.Test.GraphQLFields
  import MoodleNet.Test.Trendy
  import MoodleNet.Test.Faking

  describe "resource" do

    test "works for a guest" do
      alice = fake_user!()
      comm = fake_community!(alice)
      coll = fake_collection!(alice, comm)
      res = fake_resource!(alice, coll)
      q = resource_query()
      conn = json_conn()
      assert_resource(res, grumble_post_key(q, conn, :resource, %{resource_id: res.id}))
    end

  end

  describe "resource.my_like" do

    test "is nil for a guest or someone who does not like" do
      [alice, bob] = some_fake_users!(2)
      lucy = fake_admin!()
      comm = fake_community!(alice)
      coll = fake_collection!(alice, comm)
      res = fake_resource!(alice, coll)
      q = resource_query(fields: [my_like: like_fields()])
      for conn <- [json_conn(), user_conn(alice), user_conn(bob), user_conn(lucy)] do
        res2 = assert_resource(res, grumble_post_key(q, conn, :resource, %{resource_id: res.id}))
        assert %{"myLike" => nil} = res2
      end
    end

    test "works for a user or admin who likes it" do
      [alice, bob] = some_fake_users!(2)
      lucy = fake_admin!()
      comm = fake_community!(alice)
      coll = fake_collection!(alice, comm)
      res = fake_resource!(alice, coll)
      q = resource_query(fields: [my_like: like_fields()])
      for user <- [alice, bob, lucy] do
        like = like!(user, res)
        conn = user_conn(user)
        res2 = assert_resource(res, grumble_post_key(q, conn, :resource, %{resource_id: res.id}))
        assert %{"myLike" => like2} = res2
        assert_like(like, like2)
      end
    end

  end

  describe "resource.my_flag" do

    test "is nil for a guest or someone who does not flag" do
      [alice, bob] = some_fake_users!(2)
      lucy = fake_admin!()
      comm = fake_community!(alice)
      coll = fake_collection!(alice, comm)
      res = fake_resource!(alice, coll)
      q = resource_query(fields: [my_flag: flag_fields()])
      for conn <- [json_conn(), user_conn(alice), user_conn(bob), user_conn(lucy)] do
        res2 = assert_resource(res, grumble_post_key(q, conn, :resource, %{resource_id: res.id}))
        assert %{"myFlag" => nil} = res2
      end
    end

    test "works for a user or admin who flags it" do
      [alice, bob] = some_fake_users!(2)
      lucy = fake_admin!()
      comm = fake_community!(alice)
      coll = fake_collection!(alice, comm)
      res = fake_resource!(alice, coll)
      q = resource_query(fields: [my_flag: flag_fields()])
      for user <- [alice, bob, lucy] do
        flag = flag!(user, res)
        conn = user_conn(user)
        res2 = assert_resource(res, grumble_post_key(q, conn, :resource, %{resource_id: res.id}))
        assert %{"myFlag" => flag2} = res2
        assert_flag(flag, flag2)
      end
    end

  end

  describe "resource.creator" do

    test "works for anyone" do
      [alice, bob] = some_fake_users!(2)
      lucy = fake_admin!()
      comm = fake_community!(alice)
      coll = fake_collection!(alice, comm)
      res = fake_resource!(alice, coll)
      q = resource_query(fields: [creator: user_fields()])
      for conn <- [json_conn(), user_conn(alice), user_conn(bob), user_conn(alice), user_conn(lucy)] do
        res2 = assert_resource(res, grumble_post_key(q, conn, :resource, %{resource_id: res.id}))
        assert %{"creator" => creator} = res2
        assert_user(alice, creator)
      end
    end

    @tag :skip
    test "does not work with a private user for other users" do
    end

    @tag :skip
    test "works for a private user themselves or an instance admin" do
    end

  end

  describe "resource.collection" do

    test "works for anyone" do
      [alice, bob] = some_fake_users!(2)
      lucy = fake_admin!()
      comm = fake_community!(alice)
      coll = fake_collection!(alice, comm)
      res = fake_resource!(alice, coll)
      q = resource_query(fields: [collection: collection_fields()])
      for conn <- [json_conn(), user_conn(alice), user_conn(bob), user_conn(alice), user_conn(lucy)] do
        res2 = assert_resource(res, grumble_post_key(q, conn, :resource, %{resource_id: res.id}))
        assert %{"collection" => coll2} = res2
        assert_collection(coll, coll2)
      end
    end

  end

  describe "resource.likes" do

    test "works for anyone" do
      [alice, bob, eve] = some_fake_users!(3)
      lucy = fake_admin!()
      comm = fake_community!(alice)
      coll = fake_collection!(alice, comm)
      res = fake_resource!(alice, coll)
      likes = pam([alice, bob, eve], &like!(&1, res))
      q = resource_query(
        fields: [
          likers_subquery(
            fields: [
              context: [resource_spread()],
              creator: user_fields(),
            ]
          )
        ]
      )
      for conn <- [json_conn(), user_conn(alice), user_conn(bob), user_conn(eve), user_conn(lucy)] do
        res2 = assert_resource(res, grumble_post_key(q, conn, :resource, %{resource_id: res.id}))
        assert %{"likers" => likes2} = res2
        likes2 = assert_page(likes2, 3, 3, false, false, &(&1["id"]))
        each(likes, likes2.edges, &assert_like/2)
      end
    end
    
  end

  describe "resource.flags" do

    test "empty for a guest or non-flagging user with a public resource" do
      [alice, bob, dave, eve] = some_fake_users!(4)
      comm = fake_community!(alice)
      coll = fake_collection!(alice, comm)
      res = fake_resource!(alice, coll)
      pam([alice, bob, dave], &flag!(&1, res))
      q = resource_query(
        fields: [
          flags_subquery(
            fields: [
              context: [resource_spread()],
              creator: user_fields(),
            ]
          )
        ]
      )
      for conn <- [json_conn(), user_conn(eve)] do
        res2 = assert_resource(res, grumble_post_key(q, conn, :resource, %{resource_id: res.id}))
        assert %{"flags" => flags} = res2
        assert [] == assert_page(flags, 0, 0, false, false, &(&1["id"])).edges
      end
    end

    test "works for a user who has flagged a public resource" do
      [alice, bob, eve] = some_fake_users!(3)
      lucy = fake_admin!()
      comm = fake_community!(alice)
      coll = fake_collection!(alice, comm)
      res = fake_resource!(alice, coll)
      q = resource_query(
        fields: [
          flags_subquery(
            fields: [
              context: [resource_spread()],
              creator: user_fields(),
            ]
          )
        ]
      )
      flags = pam([alice, bob, eve], fn user ->
        flag = flag!(user, res)
        conn = user_conn(user)
        res2 = assert_resource(res, grumble_post_key(q, conn, :resource, %{resource_id: res.id}))
        assert %{"flags" => flags} = res2
        assert [flag2] = assert_page(flags, 1, 1, false, false, &(&1["id"])).edges
        assert_flag(flag, flag2)
        flag
      end)

      conn = user_conn(lucy)
      res2 = assert_resource(res, grumble_post_key(q, conn, :resource, %{resource_id: res.id}))
      assert %{"flags" => flags2} = res2
      flags2 = assert_page(flags2, 3, 3, false, false, &(&1["id"])).edges
      each(flags, flags2, &assert_flag/2)
    end

  end

end
