defmodule ValueFlows.Planning.Intent.GraphQLTest do
  use MoodleNetWeb.ConnCase, async: true

  import MoodleNet.Test.Faking
  import CommonsPub.Utils.Simulation

  import Geolocation.Simulate
  import Geolocation.Test.Faking

  import Measurement.Simulate
  import Measurement.Test.Faking

  import ValueFlows.Simulate
  import ValueFlows.Test.Faking
  alias ValueFlows.Planning.Intent.Intents

  describe "intent" do
    test "fetches an existing intent by ID" do
      user = fake_user!()
      unit = fake_unit!(user)
      intent = fake_intent!(user, unit)

      q = intent_query()
      conn = user_conn(user)
      assert_intent(grumble_post_key(q, conn, :intent, %{id: intent.id}))
    end

    test "fails for deleted intent" do
      user = fake_user!()
      unit = fake_unit!(user)
      intent = fake_intent!(user, unit)
      assert {:ok, intent} = Intents.soft_delete(intent)

      q = intent_query()
      conn = user_conn(user)
      assert [%{"status" => 404}] = grumble_post_errors(q, conn, %{id: intent.id})
    end
  end

  describe "create_intent" do
    test "creates a new intent given valid attributes" do
      user = fake_user!()
      unit = fake_unit!(user)

      q =
        create_intent_mutation(
          fields: [
            available_quantity: [:has_numerical_value, has_unit: [:id, :label]]
          ]
        )

      conn = user_conn(user)
      vars = %{intent: intent_input(unit)}
      assert intent = grumble_post_key(q, conn, :create_intent, vars)["intent"]
      assert_intent(intent)

      assert intent["availableQuantity"]["hasNumericalValue"] ==
               vars.intent["available_quantity"]["hasNumericalValue"]
    end

    test "creates a new intent given a scope" do
      user = fake_user!()
      unit = fake_unit!(user)
      another_user = fake_user!()

      q = create_intent_mutation(fields: [in_scope_of: [:__typename]])
      conn = user_conn(user)
      vars = %{intent: intent_input(unit, %{"inScopeOf" => [another_user.id]})}
      assert intent = grumble_post_key(q, conn, :create_intent, vars)["intent"]
      assert_intent(intent)
      assert [context] = intent["inScopeOf"]
      assert context["__typename"] == "User"
    end

    test "creates a new intent with a location" do
      user = fake_user!()
      unit = fake_unit!(user)
      geo = fake_geolocation!(user)

      q = create_intent_mutation(fields: [atLocation: [:id]])
      conn = user_conn(user)
      vars = %{intent: intent_input(unit, %{"atLocation" => geo.id})}
      assert intent = grumble_post_key(q, conn, :create_intent, vars)["intent"]
      assert_intent(intent)
      assert intent["atLocation"]["id"] == geo.id
    end
  end

  describe "update_intent" do
    test "updates an existing intent" do
      user = fake_user!()
      unit = fake_unit!(user)
      intent = fake_intent!(user, unit)

      q = update_intent_mutation()
      conn = user_conn(user)
      vars = %{intent: intent_input(unit, %{"id" => intent.id})}
      assert resp = grumble_post_key(q, conn, :update_intent, vars)["intent"]
      assert_intent(resp)

      assert {:ok, updated} = Intents.one(id: intent.id)
      assert updated != intent
      assert_intent(updated, resp)
      assert updated.available_quantity_id != intent.available_quantity_id
    end

    test "updates an existing intent with a scope" do
      user = fake_user!()
      another_user = fake_user!()
      unit = fake_unit!(user)
      intent = fake_intent!(user, unit)

      q = update_intent_mutation(fields: [in_scope_of: [:__typename]])
      conn = user_conn(user)

      vars = %{
        intent:
          intent_input(unit, %{
            "id" => intent.id,
            "inScopeOf" => [another_user.id]
          })
      }

      assert resp = grumble_post_key(q, conn, :update_intent, vars)["intent"]
      assert [context] = resp["inScopeOf"]
      assert context["__typename"] == "User"
    end

    test "updates an existing intent with a location" do
      user = fake_user!()
      geo = fake_geolocation!(user)
      unit = fake_unit!(user)
      intent = fake_intent!(user, unit)

      q = update_intent_mutation(fields: [atLocation: [:id]])
      conn = user_conn(user)

      vars = %{
        intent:
          intent_input(unit, %{
            "id" => intent.id,
            "atLocation" => geo.id
          })
      }

      assert resp = grumble_post_key(q, conn, :update_intent, vars)["intent"]
      assert resp["atLocation"]["id"] == geo.id
    end
  end

  describe "delete_intent" do
    test "deletes an item that is not deleted" do
      user = fake_user!()
      unit = fake_unit!(user)
      intent = fake_intent!(user, unit)

      q = delete_intent_mutation()
      conn = user_conn(user)
      assert grumble_post_key(q, conn, :delete_intent, %{id: intent.id})
    end
  end
end
