# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule ValueFlows.Proposal.ProposedIntentGraphQL do
  use Absinthe.Schema.Notation

  alias ValueFlows.Proposals

  def proposed_intent(%{id: id}, info) do
    Proposals.one_proposed_intent([:default, id: id])
  end

  def proposed_intents_edge(params, info) do
  end

  def propose_intent(%{published_in: published_in_id, publishes: publishes_id} = params, info) do
    with {:ok, published} <- ValueFlows.Proposal.GraphQL.proposal(%{id: published_in_id}, info),
         {:ok, publishes} <- ValueFlows.Planning.Intent.GraphQL.intent(%{id: publishes_id}, info),
         {:ok, proposed_intent} <- Proposals.propose_intent(published, publishes, params) do
      {:ok, %{proposed_intent | published: published, publishes: publishes}}
    end
  end

  def delete_proposed_intent(%{id: id}, info) do
    with {:ok, proposed_intent} <- proposed_intent(%{id: id}, info) do
      Proposals.delete_proposed_intent(proposed_intent)
    end
  end
end
