defmodule ValueFlows.Observation.EconomicEvent.EconomicEventsTest do
  use CommonsPub.Web.ConnCase, async: true

  import CommonsPub.Test.Faking
  import CommonsPub.Utils.{Trendy, Simulation}
  import ValueFlows.Simulate
  import Measurement.Simulate

  import ValueFlows.Test.Faking

  alias ValueFlows.Observation.EconomicEvent.EconomicEvents

  describe "one" do
    test "fetches an existing economic event by ID" do
     user = fake_user!()
     provider = fake_user!()
     receiver = fake_user!()
     action = action()
     event = fake_economic_event!(user, receiver, provider, action, %{
       input_of: fake_process!(user).id,
       output_of: fake_process!(user).id,
       resource_conforms_to: fake_resource_specification!(user).id,
       to_resource_inventoried_as: fake_economic_resource!(user).id,
       resource_inventoried_as: fake_economic_resource!(user).id,
     })

     assert {:ok, fetched} = EconomicEvents.one(id: event.id)
     assert_economic_event(fetched)
     assert {:ok, fetched} = EconomicEvents.one(user: user)
     assert_economic_event(fetched)
    end


  end

  describe "create" do
    test "can create an economic event" do
      user = fake_user!()
      provider = fake_user!()
      receiver = fake_user!()
      action = action()

      assert {:ok, event} = EconomicEvents.create(user, receiver, provider, action, economic_event())
      assert_economic_event(event)
      assert event.provider.id == provider.id
      assert event.receiver.id == receiver.id
      assert event.action.label == action.label
      assert event.creator.id == user.id
    end

    test "can create an economic event with context" do
      user = fake_user!()
      provider = fake_user!()
      receiver = fake_user!()
      action = action()
      attrs = %{
        in_scope_of: [fake_community!(user).id],
      }
      assert {:ok, event} = EconomicEvents.create(user, receiver, provider, action, economic_event(attrs))
      assert_economic_event(event)
      assert event.context.id == hd(attrs.in_scope_of)
    end

    test "can create an economic event with input and output" do
      user = fake_user!()
      provider = fake_user!()
      receiver = fake_user!()
      action = action()
      attrs = %{
        input_of: fake_process!(user).id,
        output_of: fake_process!(user).id,
      }
      assert {:ok, event} = EconomicEvents.create(user, receiver, provider, action, economic_event(attrs))
      assert_economic_event(event)
      assert event.input_of.id == attrs.input_of
      assert event.output_of.id == attrs.output_of
    end

    test "can create an economic event with resource inventoried as" do
      user = fake_user!()
      provider = fake_user!()
      receiver = fake_user!()
      action = action()
      attrs = %{
        resource_inventoried_as: fake_economic_resource!(user).id,
      }
      assert {:ok, event} = EconomicEvents.create(user, receiver, provider, action, economic_event(attrs))
      assert_economic_event(event)
      assert event.resource_inventoried_as.id == attrs.resource_inventoried_as
    end

    test "can create an economic event with to resource inventoried as" do
      user = fake_user!()
      provider = fake_user!()
      receiver = fake_user!()
      action = action()
      attrs = %{
        to_resource_inventoried_as: fake_economic_resource!(user).id,
      }
      assert {:ok, event} = EconomicEvents.create(user, receiver, provider, action, economic_event(attrs))
      assert_economic_event(event)
      assert event.to_resource_inventoried_as.id == attrs.to_resource_inventoried_as
    end

    test "can create an economic event with: resource conforms to, resourceClassifiedAs" do
      user = fake_user!()
      provider = fake_user!()
      receiver = fake_user!()
      action = action()
      attrs = %{
        resource_conforms_to: fake_resource_specification!(user).id,
        resource_classified_as: some(1..5, &url/0)
      }
      assert {:ok, event} = EconomicEvents.create(user, receiver, provider, action, economic_event(attrs))
      assert_economic_event(event)
      assert event.resource_conforms_to.id == attrs.resource_conforms_to
      assert event.resource_classified_as == attrs.resource_classified_as
    end

    test "can create an economic event with measure" do
      user = fake_user!()
      provider = fake_user!()
      receiver = fake_user!()
      unit = fake_unit!(user)
      action = action()
      measures = %{
        resource_quantity: measure(%{unit_id: unit.id}),
        effort_quantity: measure(%{unit_id: unit.id}),
      }

      assert {:ok, event} = EconomicEvents.create(user, receiver, provider, action, economic_event(measures))
      assert_economic_event(event)
      assert event.resource_quantity.id
      assert event.effort_quantity.id
    end

  end
end
