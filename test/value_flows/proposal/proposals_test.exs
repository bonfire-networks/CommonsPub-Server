# SPDX-License-Identifier: AGPL-3.0-only#
defmodule ValueFlows.Proposal.ProposalsTest do
  use MoodleNetWeb.ConnCase, async: true

  import MoodleNet.Test.Faking

  import Measurement.Simulate
  import Measurement.Test.Faking

  import ValueFlows.Simulate
  import ValueFlows.Test.Faking

  alias ValueFlows.Proposals

  describe "one" do
    test "fetches an existing proposal by ID" do
      user = fake_user!()
      proposal = fake_proposal!(user)

      assert {:ok, fetched} = Proposals.one(id: proposal.id)
      assert_proposal(proposal, fetched)
      assert {:ok, fetched} = Proposals.one(user: user)
      assert_proposal(proposal, fetched)
      # TODO
      # assert {:ok, fetched} = Intents.one(context: comm)
    end
  end

  describe "create" do
    test "can create a proposal" do
      user = fake_user!()

      assert {:ok, proposal} = Proposals.create(user, proposal())
      assert_proposal(proposal)
    end
  end

  describe "propose_intent" do
    test "creates a new proposed intent" do
      user = fake_user!()
      intent = fake_intent!(user, fake_unit!(user))
      proposal = fake_proposal!(user)

      assert {:ok, proposed_intent} =
        Proposals.propose_intent(proposal, intent, proposed_intent())
      assert_proposed_intent(proposed_intent)
    end
  end
end
