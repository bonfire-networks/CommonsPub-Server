defmodule ValueFlows.Proposal.ProposedToGraphQL do
  use Absinthe.Schema.Notation

  alias MoodleNet.GraphQL
  alias MoodleNet.Meta.Pointers
  alias ValueFlows.Proposals

  def propose_to(%{proposed_to: agent_id, proposed: proposed_id}, info) do
    with {:ok, _} <- GraphQL.current_user_or_not_logged_in(info),
         {:ok, pointer} <- Pointers.one(id: agent_id),
         :ok <- validate_context(pointer),
         agent = Pointers.follow!(pointer),
         {:ok, proposed} <- ValueFlows.Proposal.GraphQL.proposal(%{id: proposed_id}, info),
         {:ok, proposed_to} <- Proposals.propose_to(agent, proposed) do
      {:ok, %{proposed_to: %{proposed_to | proposed_to: agent, proposed: proposed}}}
    end
  end

  def delete_proposed_to(params, info) do
  end

  def validate_context(pointer) do
    if Pointers.table!(pointer).schema in valid_contexts() do
      :ok
    else
      GraphQL.not_permitted("agent")
    end
  end

  def valid_contexts do
    Application.fetch_env!(:moodle_net, Proposals)
    |> Keyword.fetch!(:valid_agent_contexts)
  end
end
