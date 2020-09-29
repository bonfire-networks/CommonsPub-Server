defmodule ValueFlows.Observation.EconomicEvent.EventsResourcesGraphQLTest do
  use CommonsPub.Web.ConnCase, async: true

  import CommonsPub.Utils.Trendy, only: [some: 2]
  import CommonsPub.Utils.Simulation
  import CommonsPub.Tag.Simulate

  import CommonsPub.Test.Faking

  import Measurement.Simulate
  import Measurement.Test.Faking

  import ValueFlows.Simulate
  import ValueFlows.Test.Faking
  alias Grumble.PP
  alias ValueFlows.Observation.EconomicEvent.EconomicEvents

  import Geolocation.Simulate
  import Geolocation.Test.Faking

  describe "EconomicEventsResourcesMutations" do
    test "create an economic resource produced by an economic event" do
      user = fake_user!()

      q = create_economic_event_mutation([fields: [provider: [:id]]], fields: [:id])

      conn = user_conn(user)

      vars = %{
        event:
          economic_event_input(%{
            "action" => "produce"
          }),
        newInventoriedResource: economic_resource_input()
      }

      assert response = grumble_post_key(q, conn, :create_economic_event, vars, "test", false)
      assert event = response["economicEvent"]
      assert resource = response["economicResource"]
      assert_economic_event(event)
      assert_economic_resource(resource)
      # assert event["resourceConformsTo"]["id"] == resource_conforms_to.id
    end

    test "fails if trying to increment a resource with a different unit" do
      user = fake_user!()
      unit = fake_unit!(user)

      resource_inventoried_as = fake_economic_resource!(user)
      IO.inspect(resource_inventoried_as)

      q = create_economic_event_mutation(fields: [resource_inventoried_as: [:id]])
      conn = user_conn(user)

      vars = %{
        event:
          economic_event_input(%{
            "action" => "raise",
            "resourceQuantity" => measure_input(unit),
            "resourceInventoriedAs" => resource_inventoried_as.id
          })
      }
      IO.inspect(vars)

      assert event =
               grumble_post_key(q, conn, :create_economic_event, vars, "test", true)[
                 "economicEvent"
               ]

      assert_economic_event(event)
      assert event["resourceInventoriedAs"]["id"] == resource_inventoried_as.id
    end

    test "create an economic event that consumes an existing resource" do
    end

    test "fails if the economic event consumes an economic resource that does not exist" do
    end

    test "fails if the economic event consumes a higher quantity of an economic resource than available" do
    end

    test "create an economic event that transfers an existing resource from a provider to a receiver" do
    end

    test "fails to transfer an economic resource if the provider does not have rights to transfer it" do
    end

    test "fails to transfer an economic resource if it does not exist" do
    end
  end
end
