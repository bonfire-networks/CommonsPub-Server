defmodule ValueFlows.Observation.EconomicEvent.EconomicEventsTest do
  use CommonsPub.Web.ConnCase, async: true

  import CommonsPub.Test.Faking
  import CommonsPub.Tag.Simulate

  import CommonsPub.Utils.{Trendy, Simulation}
  import ValueFlows.Simulate
  import Measurement.Simulate
  import Geolocation.Simulate

  import ValueFlows.Test.Faking

  alias ValueFlows.Observation.EconomicEvent.EconomicEvents

  describe "one" do
    test "fetches an existing economic event by ID" do
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

      assert {:ok, event} =
               EconomicEvents.create(
                 user,
                 economic_event(%{
                   provider: provider.id,
                   receiver: receiver.id,
                   action: action.id
                 })
               )

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
        provider: provider.id,
        receiver: receiver.id,
        action: action.id
      }

      assert {:ok, event} =
               EconomicEvents.create(user, economic_event(attrs))

      assert_economic_event(event)
      assert event.context.id == hd(attrs.in_scope_of)
    end

    test "can create an economic event with tags" do
      user = fake_user!()
      provider = fake_user!()
      receiver = fake_user!()
      action = action()

      tags = some(5, fn -> fake_category!(user).id end)
      attrs = %{tags: tags, provider: provider.id, receiver: receiver.id, action: action.id}

      assert {:ok, event} =
               EconomicEvents.create(user, economic_event(attrs))

      assert_economic_event(event)

      event = CommonsPub.Repo.preload(event, :tags)
      assert Enum.count(event.tags) == Enum.count(tags)
    end

    test "can create an economic event with input_of and output_of" do
      user = fake_user!()
      provider = fake_user!()
      receiver = fake_user!()
      action = action()

      attrs = %{
        input_of: fake_process!(user).id,
        output_of: fake_process!(user).id,
        provider: provider.id,
        receiver: receiver.id,
        action: action.id
      }

      assert {:ok, event} =
               EconomicEvents.create(user, economic_event(attrs))

      assert_economic_event(event)
      assert event.input_of.id == attrs.input_of
      assert event.output_of.id == attrs.output_of
    end

    test "can create an economic event with resource_inventoried_as" do
      user = fake_user!()
      provider = fake_user!()
      receiver = fake_user!()
      action = action()

      attrs = %{
        resource_inventoried_as: fake_economic_resource!(user).id,
        provider: provider.id,
        receiver: receiver.id,
        action: action.id
      }

      assert {:ok, event} =
               EconomicEvents.create(user, economic_event(attrs))

      assert_economic_event(event)
      assert event.resource_inventoried_as.id == attrs.resource_inventoried_as
    end

    test "can create an economic event with to_resource_inventoried_as" do
      user = fake_user!()
      provider = fake_user!()
      receiver = fake_user!()
      action = action()

      attrs = %{
        to_resource_inventoried_as: fake_economic_resource!(user).id,
        provider: provider.id,
        receiver: receiver.id,
        action: action.id
      }

      assert {:ok, event} =
               EconomicEvents.create(user, economic_event(attrs))

      assert_economic_event(event)
      assert event.to_resource_inventoried_as.id == attrs.to_resource_inventoried_as
    end

    test "can create an economic event with resource_inventoried_as and to_resource_inventoried_as" do
      user = fake_user!()
      provider = fake_user!()
      receiver = fake_user!()
      action = action()

      attrs = %{
        resource_inventoried_as: fake_economic_resource!(user).id,
        to_resource_inventoried_as: fake_economic_resource!(user).id,
        provider: provider.id,
        receiver: receiver.id,
        action: action.id
      }

      assert {:ok, event} =
               EconomicEvents.create(user, economic_event(attrs))

      assert_economic_event(event)
      assert event.resource_inventoried_as.id == attrs.resource_inventoried_as
      assert event.to_resource_inventoried_as.id == attrs.to_resource_inventoried_as
    end

    test "can create an economic event with resource_conforms_to" do
      user = fake_user!()
      provider = fake_user!()
      receiver = fake_user!()
      action = action()

      attrs = %{
        resource_conforms_to: fake_resource_specification!(user).id,
        provider: provider.id,
        receiver: receiver.id,
        action: action.id
      }

      assert {:ok, event} =
               EconomicEvents.create(user, economic_event(attrs))

      assert_economic_event(event)
      assert event.resource_conforms_to.id == attrs.resource_conforms_to
    end

    test "can create an economic event with resource_classified_as" do
      user = fake_user!()
      provider = fake_user!()
      receiver = fake_user!()
      action = action()

      attrs = %{
        resource_classified_as: some(1..5, &url/0),
        provider: provider.id,
        receiver: receiver.id,
        action: action.id
      }

      assert {:ok, event} =
               EconomicEvents.create(user, economic_event(attrs))

      assert_economic_event(event)
      assert event.resource_classified_as == attrs.resource_classified_as
    end

    test "can create an economic event with resource_quantity and effort_quantity" do
      user = fake_user!()
      provider = fake_user!()
      receiver = fake_user!()
      unit = fake_unit!(user)
      action = action()

      measures = %{
        resource_quantity: measure(%{unit_id: unit.id}),
        effort_quantity: measure(%{unit_id: unit.id}),
        provider: provider.id,
        receiver: receiver.id,
        action: action.id
      }

      assert {:ok, event} =
               EconomicEvents.create(user, economic_event(measures))

      assert_economic_event(event)
      assert event.resource_quantity.id
      assert event.effort_quantity.id
    end

    test "can create an economic event with location" do
      user = fake_user!()
      provider = fake_user!()
      receiver = fake_user!()
      action = action()
      location = fake_geolocation!(user)

      attrs = %{
        at_location: location.id,
        provider: provider.id,
        receiver: receiver.id,
        action: action.id
      }

      assert {:ok, event} =
               EconomicEvents.create(user, economic_event(attrs))

      assert_economic_event(event)
      assert event.at_location.id == attrs.at_location
    end

    test "can create an economic event triggered_by another event" do
      user = fake_user!()
      provider = fake_user!()
      receiver = fake_user!()
      action = action()
      triggered_by = fake_economic_event!(user)

      attrs = %{
        triggered_by: triggered_by.id,
        provider: provider.id,
        receiver: receiver.id,
        action: action.id
      }

      assert {:ok, event} =
               EconomicEvents.create(user, economic_event(attrs))

      assert_economic_event(event)
      assert event.triggered_by.id == attrs.triggered_by
    end
  end

  describe "update" do
    test "updates an existing event" do
      user = fake_user!()
      economic_event = fake_economic_event!(user)

      assert {:ok, updated} = EconomicEvents.update(economic_event, economic_event(%{note: "test"}))
      assert_economic_event(updated)
      assert economic_event != updated
    end

  end

end
