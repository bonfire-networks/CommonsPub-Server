# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.Collections.MutationsTest do
  use MoodleNetWeb.ConnCase, async: true
  alias MoodleNet.Test.Fake
  import MoodleNetWeb.Test.GraphQLAssertions
  import MoodleNetWeb.Test.GraphQLFields
  import MoodleNet.Test.Faking

  describe "create_collection" do

    test "works for the community creator, randomer and instance admin" do
      alice = fake_user!()
      bob = fake_user!()
      lucy = fake_user!(%{is_instance_admin: true})
      conns = [user_conn(alice), user_conn(bob), user_conn(lucy)]
      comm = fake_community!(alice)
      for conn <- conns do
        ci = Fake.collection_input()
        vars = %{"collection" => ci, "communityId" => comm.id}
        q = create_collection_mutation()
        coll = grumble_post_key(q, conn, "createCollection", vars)
        assert_collection(ci, coll)
      end
    end

    test "does not work for a guest" do
      bob = fake_user!()
      comm = fake_community!(bob)
      ci = Fake.collection_input()
      q = create_collection_mutation()
      vars = %{"collection" => ci, "communityId" => comm.id}
      assert err = grumble_post_errors(q, json_conn(), vars)
    end

  end

  describe "update_collection" do

    test "works for the community owner, collection owner or admin" do
      [alice, bob] = some_fake_users!(2)
      lucy = fake_admin!()
      comm = fake_community!(alice)
      coll = fake_collection!(bob, comm)
      conns = [user_conn(alice), user_conn(bob), user_conn(lucy)]
      for conn <- conns do
        ci = Fake.collection_update_input()
        vars = %{"collection" => ci, "collectionId" => coll.id}
        q = update_collection_mutation()
        coll = grumble_post_key(q, conn, "updateCollection", vars)
        assert_collection(Map.put(ci, "preferredUsername", coll["preferredUsername"]), coll)
      end
    end

    test "does not work for a random or a guest" do
      [alice, bob, eve] = some_fake_users!(3)
      comm = fake_community!(alice)
      coll = fake_collection!(bob, comm)
      for conn <- [user_conn(eve), json_conn()] do
        ci = Fake.collection_update_input()
        vars = %{"collection" => ci, "collectionId" => coll.id}
        q = update_collection_mutation()
        grumble_post_errors(q, conn, vars)
      end
    end

  end

end
