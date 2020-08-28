defmodule ValueFlows.Proposal.GraphQLTest do
  use MoodleNetWeb.ConnCase, async: true

  import CommonsPub.Utils.Trendy, only: [some: 2]
  import CommonsPub.Utils.Simulation
  import MoodleNet.Test.Faking

  import ValueFlows.Simulate
  import ValueFlows.Test.Faking

  describe "proposal" do
    test "fetches a proposal by ID" do
      user = fake_user!()
      proposal = fake_proposal!(user)

      q = proposal_query()
      conn = user_conn(user)
      assert proposal = grumble_post_key(q, conn, :proposal, %{id: proposal.id})
      assert_proposal(proposal)
    end
  end

  describe "proposal.publishes" do
    test "fetches all proposed intents for a proposal" do
      user = fake_user!()
      proposal = fake_proposal!(user)
      intent = fake_intent!(user)
      some(5, fn ->
        fake_proposed_intent!(proposal, intent)
      end)

      q = proposal_query(fields: [publishes: [:id]])
      conn = user_conn(user)
      assert proposal = grumble_post_key(q, conn, :proposal, %{id: proposal.id})
      assert Enum.count(proposal["publishes"]) == 5
    end
  end

  describe "proposal.publishedTo" do
  end

  describe "proposals" do
  end

  describe "createProposal" do
    test "creates a new proposal" do
      user = fake_user!()
      q = create_proposal_mutation()
      conn = user_conn(user)
      vars = %{proposal: proposal_input()}
      assert proposal = grumble_post_key(q, conn, :create_proposal, vars)["proposal"]
      assert_proposal(proposal)
    end

    test "creates a new proposal with a scope" do
      user = fake_user!()
      parent = fake_user!()

      q = create_proposal_mutation()
      conn = user_conn(user)
      vars = %{proposal: proposal_input(%{"inScopeOf" => parent.id})}
      assert proposal = grumble_post_key(q, conn, :create_proposal, vars)["proposal"]
      assert_proposal(proposal)
    end
  end

  describe "updateProposal" do
  end

  describe "deleteProposal" do
  end
end
