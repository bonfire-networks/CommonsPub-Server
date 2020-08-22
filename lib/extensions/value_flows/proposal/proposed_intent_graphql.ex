# SPDX-License-Identifier: AGPL-3.0-only
defmodule ValueFlows.Proposal.ProposedIntentGraphQL do
  use Absinthe.Schema.Notation

  alias MoodleNet.GraphQL.{
    ResolveField,
    ResolveFields,
    FetchFields
  }

  alias ValueFlows.{Proposal, Proposals}
  alias ValueFlows.Proposal.ProposedIntent

  def proposed_intent(%{id: id}, info) do
    ResolveField.run(%ResolveField{
      module: __MODULE__,
      fetcher: :fetch_proposed_intent,
      context: id,
      info: info
    })
  end

  def proposed_intents(%{id: proposal_id}, _, info) do
    ResolveFields.run(%ResolveFields{
      module: __MODULE__,
      fetcher: :fetch_proposed_intents,
      context: proposal_id,
      info: info
    })
  end

  def fetch_proposed_intent(_info, id) do
    Proposals.one_proposed_intent([:default, id: id])
  end

  def fetch_proposed_intents(_info, ids) do
    FetchFields.run(%FetchFields{
      queries: Proposal.ProposedIntentQueries,
      query: ProposedIntent,
      group_fn: & &1.publishes_id,
      filters: [:default, publishes_id: ids]
    })
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
    with {:ok, proposed_intent} <- proposed_intent(%{id: id}, info),
         {:ok, _} <- Proposals.delete_proposed_intent(proposed_intent) do
      {:ok, true}
    end
  end
end
