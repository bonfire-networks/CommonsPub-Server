# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule ValueFlows.Proposal.ProposedIntentGraphQL do
  use Absinthe.Schema.Notation

  alias MoodleNet.GraphQL.{
    ResolveField,
    ResolveFields,
    ResolveRootPage,
    FetchPage
  }

  alias ValueFlows.Proposals

  def proposed_intent(%{id: id}, info) do
    ResolveField.run(%ResolveField{
      module: __MODULE__,
      fetcher: :fetch_proposed_intent,
      context: id,
      info: info
    })
  end

  def proposed_intent_edges(%{published_in_ids: ids}, %{} = page_opts, info) do
    ResolveFields.run(%ResolveFields{
      module: __MODULE__,
      fetcher: :fetch_propose_intent_edges,
      context: ids,
      info: info
    })
  end

  def fetch_proposed_intent(info, id) do
    Proposals.one_proposed_intent([:default, id: id])
  end

  def fetch_propose_intent_edges(_page_opts, _info, ids) do
    Proposals.many_proposed_intents([:default, id: List.flatten(ids)])
  end

  def propose_intent(%{published_in: published_in_id, publishes: publishes_id} = params, info) do
    with {:ok, published_in} <-
           ValueFlows.Proposal.GraphQL.proposal(%{id: published_in_id}, info),
         {:ok, publishes} <- ValueFlows.Planning.Intent.GraphQL.intent(%{id: publishes_id}, info),
         {:ok, proposed_intent} <- Proposals.propose_intent(published_in, publishes, params) do
      {:ok,
       %{proposed_intent: %{proposed_intent | published_in: published_in, publishes: publishes}}}
    end
  end

  def delete_proposed_intent(%{id: id}, info) do
    with {:ok, proposed_intent} <- proposed_intent(%{id: id}, info) do
      Proposals.delete_proposed_intent(proposed_intent)
    end
  end
end
