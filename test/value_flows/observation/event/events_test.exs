defmodule ValueFlows.Observation.EconomicEvent.EconomicEventsTest do
  use CommonsPub.Web.ConnCase, async: true

  import CommonsPub.Test.Faking

  import ValueFlows.Simulate
  import ValueFlows.Test.Faking

  alias ValueFlows.Observation.EconomicEvent.EconomicEvents

  describe "one" do
    test "fetches an existing economic event by ID" do
     user = fake_user!()

     event = fake_economic_event!(user, %{
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

    test "cannot fetch a deleted economic event" do

    end
  end

end
