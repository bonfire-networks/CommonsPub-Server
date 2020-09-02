defmodule ValueFlows.Proposal.ProposedToGraphQLTest do
  use CommonsPub.Web.ConnCase, async: true

  import CommonsPub.Utils.Simulation
  import CommonsPub.Test.Faking

  import ValueFlows.Simulate
  import ValueFlows.Test.Faking

  describe "propose_to" do
    test "creates a new proposed to item" do
      user = fake_user!()
      proposal = fake_proposal!(user)
      agent = fake_user!()

      q = propose_to_mutation(fields: [proposed: [:id], proposed_to: [:id]])

      conn = user_conn(user)

      vars = %{
        "proposed" => proposal.id,
        "proposedTo" => agent.id
      }

      assert proposed_to = grumble_post_key(q, conn, :propose_to, vars)["proposedTo"]
      assert_proposed_to(proposed_to)
      assert proposed_to["proposed"]["id"] == proposal.id
      assert proposed_to["proposedTo"]["id"] == agent.id
    end
  end
end
