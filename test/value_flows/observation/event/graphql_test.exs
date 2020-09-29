defmodule ValueFlows.Observation.EconomicEvent.GraphQLTest do
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

  describe "EconomicEvent" do
    test "fetches an economic event by ID" do
      user = fake_user!()
      provider = fake_user!()
      receiver = fake_user!()
      action = action()

      event =
        fake_economic_event!(user, %{
          provider: provider.id,
          receiver: receiver.id,
          action: action.id,
          input_of: fake_process!(user).id,
          output_of: fake_process!(user).id,
          resource_conforms_to: fake_resource_specification!(user).id,
          to_resource_inventoried_as: fake_economic_resource!(user).id,
          resource_inventoried_as: fake_economic_resource!(user).id
        })

      q = economic_event_query()
      conn = user_conn(user)
      assert fetched = grumble_post_key(q, conn, :economic_event, %{id: event.id})
      assert_economic_event(fetched)
    end

    test "fails if has been deleted" do
      user = fake_user!()
      provider = fake_user!()
      receiver = fake_user!()
      action = action()

      event =
        fake_economic_event!(user, %{
          provider: provider.id,
          receiver: receiver.id,
          action: action.id,
          input_of: fake_process!(user).id,
          output_of: fake_process!(user).id,
          resource_conforms_to: fake_resource_specification!(user).id,
          to_resource_inventoried_as: fake_economic_resource!(user).id,
          resource_inventoried_as: fake_economic_resource!(user).id
        })

      q = economic_event_query()
      conn = user_conn(user)

      assert {:ok, spec} = EconomicEvents.soft_delete(event)

      assert [%{"code" => "not_found", "path" => ["economicEvent"], "status" => 404}] =
               grumble_post_errors(q, conn, %{id: event.id})
    end
  end

  describe "economicEvent.inScopeOf" do
    test "return the scope of the intent" do
      user = fake_user!()
      provider = fake_user!()
      receiver = fake_user!()
      action = action()

      parent = fake_user!()

      event =
        fake_economic_event!(user, %{
          provider: provider.id,
          receiver: receiver.id,
          action: action.id,
          in_scope_of: parent.id
        })

      q = economic_event_query(fields: [in_scope_of: [:__typename]])
      conn = user_conn(user)
      assert fetched = grumble_post_key(q, conn, :economic_event, %{id: event.id})
      assert hd(fetched["inScopeOf"])["__typename"] == "User"
    end
  end

  describe "EconomicEvents" do
    test "return a list of economicEvents" do
      user = fake_user!()
      provider = fake_user!()
      receiver = fake_user!()
      action = action()

      events =
        some(5, fn ->
          fake_economic_event!(user, %{
            provider: provider.id,
            receiver: receiver.id,
            action: action.id
          })
        end)

      # deleted
      some(2, fn ->
        event =
          fake_economic_event!(user, %{
            provider: provider.id,
            receiver: receiver.id,
            action: action.id
          })

        {:ok, event} = EconomicEvents.soft_delete(event)
        event
      end)

      q = economic_events_query()
      conn = user_conn(user)
      assert fetched_economic_events = grumble_post_key(q, conn, :economic_events, %{})
      assert Enum.count(events) == Enum.count(fetched_economic_events)
    end
  end

  describe "EconomicEventsPages" do
    test "fetches all items that are not deleted" do
      user = fake_user!()
      provider = fake_user!()
      receiver = fake_user!()
      action = action()

      events =
        some(5, fn ->
          fake_economic_event!(user, %{
            provider: provider.id,
            receiver: receiver.id,
            action: action.id
          })
        end)

      # deleted
      some(2, fn ->
        event =
          fake_economic_event!(user, %{
            provider: provider.id,
            receiver: receiver.id,
            action: action.id
          })

        {:ok, event} = EconomicEvents.soft_delete(event)
        event
      end)

      q = economic_events_pages_query()
      conn = user_conn(user)
      assert page = grumble_post_key(q, conn, :economic_events_pages, %{})
      assert Enum.count(events) == page["totalCount"]
    end
  end

  describe "createEconomicEvent" do
    test "create a new economic event" do
      user = fake_user!()
      provider = fake_user!()
      receiver = fake_user!()
      action = action()
      q = create_economic_event_mutation()
      conn = user_conn(user)

      vars = %{
        event:
          economic_event_input(%{
            provider: provider.id,
            receiver: receiver.id,
            action: action.id
          })
      }

      assert event = grumble_post_key(q, conn, :create_economic_event, vars)["economicEvent"]
      assert_economic_event(event)
    end

    test "creates a new economic event with a scope" do
      user = fake_user!()
      provider = fake_user!()
      receiver = fake_user!()
      action = action()
      parent = fake_user!()

      q = create_economic_event_mutation(fields: [in_scope_of: [:__typename]])
      conn = user_conn(user)

      vars = %{
        event:
          economic_event_input(%{
            "inScopeOf" => [parent.id],
            "provider" => provider.id,
            "receiver" => receiver.id,
            "action" => action.id
          })
      }

      assert event = grumble_post_key(q, conn, :create_economic_event, vars)["economicEvent"]
      assert_economic_event(event)
      assert hd(event["inScopeOf"])["__typename"] == "User"
    end

    test "create an economic event with an input and an output" do
      user = fake_user!()
      provider = fake_user!()
      receiver = fake_user!()
      process = fake_process!(user)
      action = action()
      q = create_economic_event_mutation(fields: [input_of: [:id], output_of: [:id]])
      conn = user_conn(user)

      vars = %{
        event:
          economic_event_input(%{
            "inputOf" => process.id,
            "outputOf" => process.id,
            "provider" => provider.id,
            "receiver" => receiver.id,
            "action" => action.id
          })
      }

      assert event = grumble_post_key(q, conn, :create_economic_event, vars)["economicEvent"]
      assert_economic_event(event)
      assert event["inputOf"]["id"] == process.id
      assert event["outputOf"]["id"] == process.id
    end

    test "create an economic event with a resourceInventoriedAs" do
      user = fake_user!()
      provider = fake_user!()
      receiver = fake_user!()
      resource_inventoried_as = fake_economic_resource!(user)
      action = action()
      q = create_economic_event_mutation(fields: [resource_inventoried_as: [:id]])
      conn = user_conn(user)

      vars = %{
        event:
          economic_event_input(%{
            "resourceInventoriedAs" => resource_inventoried_as.id,
            "provider" => provider.id,
            "receiver" => receiver.id,
            "action" => action.id
          })
      }

      assert event = grumble_post_key(q, conn, :create_economic_event, vars)["economicEvent"]
      assert_economic_event(event)
      assert event["resourceInventoriedAs"]["id"] == resource_inventoried_as.id
    end

    test "create an economic event with to resource Inventoried as" do
      user = fake_user!()
      provider = fake_user!()
      receiver = fake_user!()
      resource_inventoried_as = fake_economic_resource!(user)
      action = action()
      q = create_economic_event_mutation(fields: [to_resource_inventoried_as: [:id]])
      conn = user_conn(user)

      vars = %{
        event:
          economic_event_input(%{
            "toResourceInventoriedAs" => resource_inventoried_as.id,
            "provider" => provider.id,
            "receiver" => receiver.id,
            "action" => action.id
          })
      }

      assert event = grumble_post_key(q, conn, :create_economic_event, vars)["economicEvent"]
      assert_economic_event(event)
      assert event["toResourceInventoriedAs"]["id"] == resource_inventoried_as.id
    end

    test "create an economic event with resource conforms to" do
      user = fake_user!()
      provider = fake_user!()
      receiver = fake_user!()
      resource_conforms_to = fake_resource_specification!(user)
      action = action()
      q = create_economic_event_mutation(fields: [resource_conforms_to: [:id]])
      conn = user_conn(user)

      vars = %{
        event:
          economic_event_input(%{
            "resourceConformsTo" => resource_conforms_to.id,
            "provider" => provider.id,
            "receiver" => receiver.id,
            "action" => action.id
          })
      }

      assert event = grumble_post_key(q, conn, :create_economic_event, vars)["economicEvent"]
      assert_economic_event(event)
      assert event["resourceConformsTo"]["id"] == resource_conforms_to.id
    end

    test "create an economic event with measurements" do
    end

    test "create an economic event with location" do
      user = fake_user!()
      provider = fake_user!()
      receiver = fake_user!()
      geo = fake_geolocation!(user)
      action = action()
      q = create_economic_event_mutation(fields: [at_location: [:id]])
      conn = user_conn(user)

      vars = %{
        event:
          economic_event_input(%{
            "at_location" => geo.id,
            "provider" => provider.id,
            "receiver" => receiver.id,
            "action" => action.id
          })
      }

      assert event = grumble_post_key(q, conn, :create_economic_event, vars)["economicEvent"]
      assert_economic_event(event)
      assert event["atLocation"]["id"] == geo.id
    end

    test "create an economic event triggered by another economic event" do
      user = fake_user!()
      provider = fake_user!()
      receiver = fake_user!()
      action = action()
      trigger = fake_economic_event!(user)
      q = create_economic_event_mutation(fields: [triggered_by: [:id]])
      conn = user_conn(user)

      vars = %{
        event:
          economic_event_input(%{
            "triggered_by" => trigger.id,
            "provider" => provider.id,
            "receiver" => receiver.id,
            "action" => action.id
          })
      }

      assert event = grumble_post_key(q, conn, :create_economic_event, vars)["economicEvent"]
      assert_economic_event(event)
      assert event["triggeredBy"]["id"] == trigger.id
    end

    test "create an economic event with tags" do
      user = fake_user!()
      provider = fake_user!()
      receiver = fake_user!()
      action = action()
      tags = some(5, fn -> fake_category!(user).id end)

      q = create_economic_event_mutation(fields: [tags: [:__typename]])
      conn = user_conn(user)

      vars = %{
        event:
          economic_event_input(%{
            "tags" => tags,
            "provider" => provider.id,
            "receiver" => receiver.id,
            "action" => action.id
          })
      }

      assert event = grumble_post_key(q, conn, :create_economic_event, vars)["economicEvent"]

      assert_economic_event(event)
      assert hd(event["tags"])["__typename"] == "Category"
    end

    test "create an economic resource produced by an economic event" do
      user = fake_user!()
      provider = fake_user!()
      receiver = fake_user!()
      # action = action()
      # q = create_economic_event_mutation(fields: [provider: [:id]])
      q = create_economic_event_mutation([fields: [provider: [:id]]], [fields: [:id]])
     # q = create_economic_event_mutation(%{event: [fields: [provider: [:id]]], resource: [fields: [:id]]})

      conn = user_conn(user)

      vars = %{
        event:
          economic_event_input(%{
            "provider" => provider.id,
            "receiver" => receiver.id,
            "action" => "produce"
          }),
        newInventoriedResource: economic_resource_input()
      }

      assert response = grumble_post_key(q, conn, :create_economic_event, vars, "test", true)
      assert event = response["economicEvent"]
      assert resource = response["economicResource"]
      assert_economic_event(event)
      assert_economic_resource(resource)
      # assert event["resourceConformsTo"]["id"] == resource_conforms_to.id
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

  describe "updateEconomicEvent" do
    test "update an existing economic event" do
    end

    test "fails if it has previously been deleted" do
    end
  end

  describe "deleteEconomicEvent" do
    test "deletes an existing economic event" do
    end

    test "fails to delete an economic resource if the user does not have rights to delete it" do
    end

  end
end
