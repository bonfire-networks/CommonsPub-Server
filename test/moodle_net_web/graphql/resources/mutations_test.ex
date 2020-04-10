# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.Resources.MutationsTest do
  use MoodleNetWeb.ConnCase, async: true
  alias MoodleNet.Test.Fake
  import MoodleNetWeb.Test.GraphQLAssertions
  import MoodleNetWeb.Test.GraphQLFields
  import MoodleNet.Test.Trendy
  import MoodleNet.Test.Faking

  describe "create_resource" do

    test "works for users" do
      [alice, bob, eve] = some_fake_users!(3)
      lucy = fake_admin!()
      comm = fake_community!(alice)
      coll = fake_collection!(bob, comm)
      q = create_resource_mutation()
      for conn <- [user_conn(alice), user_conn(bob), user_conn(eve), user_conn(lucy)] do
        ri = Fake.resource_input()
        ci = Fake.content_input()

        vars = %{collection_id: coll.id, resource: ri}

        # FIXME: grumbe_post_* should deal with uploads
        {vars, files} =
          case ci[:upload] do
            %Plug.Upload{} = upload ->
              {Map.put(vars, :content, %{upload: "upload"}), %{upload: upload}}

            _ ->
              {Map.put(vars, :content, ci), %{}}
          end

        assert_resource(grumble_post_key(q, conn, :create_resource, vars, files))
      end
    end

    test "does not work for a guest" do
      alice = fake_user!()
      comm = fake_community!(alice)
      coll = fake_collection!(alice, comm)
      q = create_resource_mutation()
      conn = json_conn()
      ri = Fake.resource_input()
      ci = Fake.content_input()
      vars = %{collection_id: coll.id, resource: ri, content: ci}
      assert_not_logged_in(grumble_post_errors(q, conn, vars), ["createResource"])
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
        assert_resource(ri, grumble_post_key(q, conn, :update_resource, vars))
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
      assert_not_logged_in(grumble_post_errors(q, conn, vars), ["updateResource"])
    end

  end

  describe "copy_resource" do

    test "works for a user" do
      [alice, bob] = some_fake_users!(2)
      comm = fake_community!(alice)
      coll = fake_collection!(alice, comm)
      coll2 = fake_collection!(alice, comm)
      resource = fake_resource!(alice, coll)
      conn = user_conn(bob)
      q = copy_resource_mutation()
      vars = %{resource_id: resource.id, collection_id: coll2.id}
      assert_copied_resource(resource, grumble_post_key(q, conn, :copy_resource, vars))
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
      assert_not_logged_in(grumble_post_errors(q, conn, vars), ["copyResource"])
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
