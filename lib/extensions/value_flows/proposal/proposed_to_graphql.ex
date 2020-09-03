defmodule ValueFlows.Proposal.ProposedToGraphQL do
  use Absinthe.Schema.Notation

  alias CommonsPub.GraphQL
  alias CommonsPub.Meta.Pointers
  alias ValueFlows.Proposal.Proposals

  alias CommonsPub.GraphQL.ResolveField

  def proposed_to(%{id: id}, info) do
    ResolveField.run(%ResolveField{
      module: __MODULE__,
      fetcher: :fetch_proposed_to,
      context: id,
      info: info
    })
  end

  def fetch_proposed_to(_info, id) do
    Proposals.one_proposed_to([:default, id: id])
  end

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

  def delete_proposed_to(%{id: id}, info) do
    with {:ok, _} <- GraphQL.current_user_or_not_logged_in(info),
         {:ok, proposed_to} <- proposed_to(%{id: id}, info),
         {:ok, _} <- Proposals.delete_proposed_to(proposed_to) do
      {:ok, true}
    end
  end

  def validate_context(pointer) do
    if Pointers.table!(pointer).schema in valid_contexts() do
      :ok
    else
      GraphQL.not_permitted("agent")
    end
  end

  def valid_contexts do
    CommonsPub.Config.get!(Proposals)
    |> Keyword.fetch!(:valid_agent_contexts)
  end
end
