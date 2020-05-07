# # MoodleNet: Connecting and empowering educators worldwide
# # Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# # SPDX-License-Identifier: AGPL-3.0-only
defmodule Measurement.UnitsTest do
  use MoodleNetWeb.ConnCase, async: true

  import MoodleNetWeb.Test.Automaton
  import MoodleNetWeb.Test.GraphQLAssertions
  import MoodleNetWeb.Test.GraphQLFields
  import MoodleNet.Test.Trendy
  import MoodleNet.Test.Faking
  import MoodleNetWeb.Test.Orderings
  import MoodleNetWeb.Test.Automaton
  import MoodleNet.Common.Enums
  import Grumble
  import Zest
  alias MoodleNet.Test.Fake

  import Measurement.Test.Faking
  alias Measurement.Unit
  alias Measurement.Unit.Units

  describe "one" do
    test "returns an item if it exists" do
      user = fake_user!()
      comm = fake_community!(user)
      unit = fake_unit!(user, comm)

      assert {:ok, fetched} = Units.one(id: unit.id)
      assert_unit(unit, fetched)
      assert {:ok, fetched} = Units.one(user: user)
      assert_unit(unit, fetched)
      assert {:ok, fetched} = Units.one(community_id: comm.id)
      assert_unit(unit, fetched)
    end

    test "returns NotFound if item is missing" do
      assert {:error, %MoodleNet.Common.NotFoundError{}} = Units.one(id: Fake.ulid())
    end
  end

  describe "create without community" do
    test "creates a new unit" do
      user = fake_user!()
      assert {:ok, unit = %Unit{}} = Units.create(user, unit())
      assert unit.creator_id == user.id
    end
  end

  describe "create with community" do
    test "creates a new unit" do
      user = fake_user!()
      comm = fake_community!(user)

      assert {:ok, unit = %Unit{}} = Units.create(user, comm, unit())
      assert unit.creator_id == user.id
      assert unit.community_id == comm.id
    end

    test "fails with invalid attributes" do
      assert {:error, %Ecto.Changeset{}} = Units.create(fake_user!(), %{})
    end
  end

  describe "update" do
    test "updates a a unit" do
      user = fake_user!()
      comm = fake_community!(user)
      unit = fake_unit!(user, comm, %{label: "Bottle Caps", symbol: "C"})
      assert {:ok, updated} = Units.update(unit, %{label: "Rad", symbol: "rad"})
      assert unit != updated
    end
  end

  # describe "units" do

  #   test "works for a guest" do
  #     users = some_fake_users!(3)
  #     communities = some_fake_communities!(3, users) # 9
  #     units = some_fake_collections!(1, users, communities) # 27
  #     root_page_test %{
  #       query: units_query(),
  #       connection: json_conn(),
  #       return_key: :units,
  #       default_limit: 10,
  #       total_count: 27,
  #       data: order_follower_count(units),
  #       assert_fn: &assert_unit/2,
  #       cursor_fn: &[&1.id],
  #       after: :collections_after,
  #       before: :collections_before,
  #       limit: :collections_limit,
  #     }
  #   end

  # end
end
