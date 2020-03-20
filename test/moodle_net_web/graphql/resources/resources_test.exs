# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.ResourcesTest do
  use MoodleNetWeb.ConnCase, async: true
  alias MoodleNet.Test.Fake
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
      assert_resource(res, gruff_post_key(q, conn, :resource, %{resource_id: res.id}))
    end

  end

  describe "resource.myLike" do

    test "is nil for a guest or someone who does not like" do
      [alice, bob] = some_fake_users!(2)
      lucy = fake_admin!()
      comm = fake_community!(alice)
      coll = fake_collection!(alice, comm)
      res = fake_resource!(alice, coll)
      q = resource_query(fields: [my_like: like_fields()])
      for conn <- [json_conn(), user_conn(alice), user_conn(bob), user_conn(lucy)] do
        res2 = assert_resource(res, gruff_post_key(q, conn, :resource, %{resource_id: res.id}))
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
        res2 = assert_resource(res, gruff_post_key(q, conn, :resource, %{resource_id: res.id}))
        assert %{"myLike" => like2} = res2
        assert_like(like, like2)
      end
    end

  end

  describe "resource.myFlag" do

    test "is nil for a guest or someone who does not flag" do
      [alice, bob] = some_fake_users!(2)
      lucy = fake_admin!()
      comm = fake_community!(alice)
      coll = fake_collection!(alice, comm)
      res = fake_resource!(alice, coll)
      q = resource_query(fields: [my_flag: flag_fields()])
      for conn <- [json_conn(), user_conn(alice), user_conn(bob), user_conn(lucy)] do
        res2 = assert_resource(res, gruff_post_key(q, conn, :resource, %{resource_id: res.id}))
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
        res2 = assert_resource(res, gruff_post_key(q, conn, :resource, %{resource_id: res.id}))
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
        res2 = assert_resource(res, gruff_post_key(q, conn, :resource, %{resource_id: res.id}))
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
        res2 = assert_resource(res, gruff_post_key(q, conn, :resource, %{resource_id: res.id}))
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
        res2 = assert_resource(res, gruff_post_key(q, conn, :resource, %{resource_id: res.id}))
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
        res2 = assert_resource(res, gruff_post_key(q, conn, :resource, %{resource_id: res.id}))
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
        res2 = assert_resource(res, gruff_post_key(q, conn, :resource, %{resource_id: res.id}))
        assert %{"flags" => flags} = res2
        assert [flag2] = assert_page(flags, 1, 1, false, false, &(&1["id"])).edges
        assert_flag(flag, flag2)
        flag
      end)

      conn = user_conn(lucy)
      res2 = assert_resource(res, gruff_post_key(q, conn, :resource, %{resource_id: res.id}))
      assert %{"flags" => flags2} = res2
      flags2 = assert_page(flags2, 3, 3, false, false, &(&1["id"])).edges
      each(flags, flags2, &assert_flag/2)
    end

  end

  ### mutations

  describe "create_resource" do

    test "works for users" do
      [alice, bob, eve] = some_fake_users!(3)
      lucy = fake_admin!()
      comm = fake_community!(alice)
      coll = fake_collection!(bob, comm)
      q = create_resource_mutation()
      for conn <- [user_conn(alice), user_conn(bob), user_conn(eve), user_conn(lucy)] do
        ri = Fake.resource_input()
        vars = %{collection_id: coll.id, resource: ri}
        assert_resource(ri, gruff_post_key(q, conn, :create_resource, vars))
      end
    end

    test "does not work for a guest" do
      alice = fake_user!()
      comm = fake_community!(alice)
      coll = fake_collection!(alice, comm)
      q = create_resource_mutation()
      conn = json_conn()
      ri = Fake.resource_input()
      vars = %{collection_id: coll.id, resource: ri}
      assert_not_logged_in(gruff_post_errors(q, conn, vars), ["createResource"])
    end

  end

  describe "update_resource" do

    test "works for the resource, collection or community creator or an admin" do
      [alice, bob, eve] = some_fake_users!(3)
      lucy = fake_admin!()
      comm = fake_community!(alice)
      coll = fake_collection!(bob, comm)
      resource = fake_resource!(eve, coll)
      q = update_resource_mutation()
      for conn <- [user_conn(alice), user_conn(bob), user_conn(eve), user_conn(lucy)] do
        ri = Fake.resource_input()
        vars = %{resource_id: resource.id, resource: ri}
        assert_resource(ri, gruff_post_key(q, conn, :update_resource, vars))
      end
    end

    test "does not work for a guest" do
      alice = fake_user!()
      comm = fake_community!(alice)
      coll = fake_collection!(alice, comm)
      resource = fake_resource!(alice, coll)
      conn = json_conn()
      q = update_resource_mutation()
      ri = Fake.resource_input()
      vars = %{resource_id: resource.id, resource: ri}
      assert_not_logged_in(gruff_post_errors(q, conn, vars), ["updateResource"])
    end

  end

  describe "copyResource" do

    test "works for a user" do
      [alice, bob] = some_fake_users!(2)
      comm = fake_community!(alice)
      coll = fake_collection!(alice, comm)
      coll2 = fake_collection!(alice, comm)
      resource = fake_resource!(alice, coll)
      conn = user_conn(bob)
      q = copy_resource_mutation()
      vars = %{resource_id: resource.id, collection_id: coll2.id}
      assert_copied_resource(resource, gruff_post_key(q, conn, :copy_resource, vars))
    end

    test "does not work for a guest" do
      alice = fake_user!()
      comm = fake_community!(alice)
      coll = fake_collection!(alice, comm)
      coll2 = fake_collection!(alice, comm)
      resource = fake_resource!(alice, coll)
      conn = json_conn()
      q = copy_resource_mutation()
      vars = %{resource_id: resource.id, collection_id: coll2.id}
      assert_not_logged_in(gruff_post_errors(q, conn, vars), ["copyResource"])
    end
  end

  describe "delete (via common)" do
    @tag :skip
    test "works for creator" do
    end
    @tag :skip
    test "works for collection creator" do
    end
    @tag :skip
    test "works for community creator" do
    end
    @tag :skip
    test "works for admin" do
    end
    @tag :skip
    test "doesn't work for random" do
    end
    @tag :skip
    test "doesn't work for guest" do
    end
  end
  describe "follow (via common)" do
    @tag :skip
    test "does not work" do
    end
  end

end
