# SPDX-License-Identifier: AGPL-3.0-only
defmodule Measurement.GraphQLTest do
  use MoodleNetWeb.ConnCase, async: true

  import MoodleNet.Test.Faking
  import Measurement.Test.Faking
  alias Measurement.{Units, Measures}

  describe "unit" do
    test "fetches an existing unit by ID" do
      user = fake_user!()
      unit = fake_unit!(user)

      q = unit_query()
      conn = user_conn(user)
      assert_unit(grumble_post_key(q, conn, :unit, %{id: unit.id}))
    end

    # TODO when soft-deletion is done
    @tag :skip
    test "fails for deleted units" do
    end

    test "fails if ID is missing" do
      user = fake_user!()
      q = unit_query()
      conn = user_conn(user)
      vars = %{id: Ecto.ULID.generate()}
      assert [%{"status" => 404}] = grumble_post_errors(q, conn, vars)
    end
  end

  describe "create_unit" do
    test "creates a new unit given valid attributes" do
      user = fake_user!()

      q = create_unit_mutation()
      conn = user_conn(user)
      vars = %{unit: unit_input()}
      assert_unit(grumble_post_key(q, conn, :create_unit, vars)["unit"])
    end

    test "creates a new unit with a scope" do
      user = fake_user!()
      comm = fake_community!(user)

      q = create_unit_mutation(fields: [in_scope_of: [:__typename]])
      conn = user_conn(user)
      vars = %{unit: unit_input(), in_scope_of: comm.id}
      assert_unit(grumble_post_key(q, conn, :create_unit, vars)["unit"])
    end
  end

  describe "update_unit" do
    test "updates an existing unit" do
      user = fake_user!()
      unit = fake_unit!(user)

      q = update_unit_mutation()
      conn = user_conn(user)
      vars = %{unit: Map.put(unit_input(), "id", unit.id)}
      assert_unit(grumble_post_key(q, conn, :update_unit, vars)["unit"])
    end
  end
end
