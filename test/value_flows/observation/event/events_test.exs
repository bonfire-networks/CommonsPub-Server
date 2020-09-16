defmodule ValueFlows.Observation.EconomicEvent.EconomicEventsTest do
  use CommonsPub.Web.ConnCase, async: true

  import CommonsPub.Test.Faking

  import ValueFlows.Simulate
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

  end
end
