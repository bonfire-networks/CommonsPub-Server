defmodule ValueFlows.Planning.Intent.GraphQLTest do
  use MoodleNetWeb.ConnCase, async: true

  import MoodleNet.Test.Faking
  import Measurement.Test.Faking
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

    # TODO: when soft-deletion is done
    @tag :skip
    test "fails for deleted intent" do
    end
  end

  describe "create_intent" do
    test "creates a new intent given valid attributes" do
      user = fake_user!()
      unit = fake_unit!(user)

      q = create_intent_mutation()
      conn = user_conn(user)
      vars = %{intent: intent_input(unit)}
      assert_intent(grumble_post_key(q, conn, :create_intent, vars)["intent"])
    end

    @tag :skip
    test "creates a new intent given a scope" do
    end
  end

  describe "update_intent" do

  end

  describe "delete_intent" do

  end
end
