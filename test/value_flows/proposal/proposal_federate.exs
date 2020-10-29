defmodule ValueFlows.Proposal.FederateTest do
  use CommonsPub.DataCase, async: false

  import CommonsPub.Utils.Trendy, only: [some: 2]
  import CommonsPub.Utils.Simulation
  import CommonsPub.Test.Faking

  import Geolocation.Simulate

  import ValueFlows.Simulate
  import ValueFlows.Test.Faking

  @debug false
  @schema CommonsPub.Web.GraphQL.Schema

  describe "proposal" do

    test "federates/publishes a proposal" do
      user = fake_user!()

      parent = fake_user!()

      location = fake_geolocation!(user)

      proposal = fake_proposal!(user, parent, %{eligible_location_id: location.id})

      intent = fake_intent!(user)

      some(5, fn ->
        fake_proposed_intent!(proposal, intent)
      end)

      some(5, fn ->
        fake_proposed_to!(fake_user!(), proposal)
      end)

      assert {:ok, activity} = CommonsPub.ActivityPub.Publisher.publish("create", proposal)
      # IO.inspect(activity)

      # assert activity.object.pointer_id == proposal.id
      assert activity.local == true
      # assert activity.object.local == true

      # assert_proposal_full(activity.object)
    end
  end
end
