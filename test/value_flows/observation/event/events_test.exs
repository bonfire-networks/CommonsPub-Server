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
      attrs = {}

    end

  end
end
