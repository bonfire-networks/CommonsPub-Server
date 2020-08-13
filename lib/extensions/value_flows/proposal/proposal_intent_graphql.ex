# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule ValueFlows.Proposal.ProposalIntentGraphQL do
  use Absinthe.Schema.Notation

  def proposed_intent_edge(params, info) do
  end

  def propose_intent(%{published_in: published_in_id, publishes: publishes_id}, info) do
  end

  def delete_proposed_intent(%{id: id}, info) do
  end
end
