# SPDX-License-Identifier: AGPL-3.0-only
defmodule ValueFlows.Planning.Intent.IntentsTest do
  use MoodleNetWeb.ConnCase, async: true

  import MoodleNet.Test.Faking
  import Measurement.Test.Faking
  import ValueFlows.Test.Faking

  alias ValueFlows.Planning.Intent.Intents

  describe "one" do
    test "fetches an existing intent by ID" do
      user = fake_user!()
      intent = fake_intent!(user)

      assert {:ok, fetched} = Intents.one(id: intent.id)
      assert_intent(intent, fetched)
      assert {:ok, fetched} = Intents.one(user: user)
      assert_intent(intent, fetched)
      # TODO
      # assert {:ok, fetched} = Intents.one(context: comm)
    end
  end

  describe "create" do
    test "can create an intent" do
      user = fake_user!()
      unit = fake_unit!(user)

      measures = %{
        resource_quantity: fake_measure!(user, unit),
        effort_quantity: fake_measure!(user, unit),
        available_quantity: fake_measure!(user, unit),
      }
      assert {:ok, intent} = Intents.create(user, measures, intent())
      assert_intent(intent)
      assert intent.resource_quantity_id == measures.resource_quantity.id
      assert intent.effort_quantity_id == measures.effort_quantity.id
      assert intent.available_quantity_id == measures.available_quantity.id
    end

    test "can create an intent with a context" do
      refute :unimplemented
    end
  end

  describe "update" do
    
  end
end
