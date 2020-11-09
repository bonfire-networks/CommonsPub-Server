# SPDX-License-Identifier: AGPL-3.0-only
defmodule ValueFlows.Claim.Claims do
  alias CommonsPub.Repo
  alias CommonsPub.Users.User

  alias ValueFlows.Claim
  alias ValueFlows.Claim.Queries

  alias CommonsPub.Meta.Pointers

  def one(filters), do: Repo.single(Queries.query(Claim, filters))

  def many(filters \\ []), do: {:ok, Repo.all(Queries.query(Claim, filters))}

  def create(%User{} = creator, %{id: _} = provider, %{id: _} = receiver, %{} = attrs) do
    Repo.transact_with(fn ->
      attrs = prepare_attrs(attrs)

      with {:ok, provider_ptr} <- Pointers.one(id: provider.id),
           {:ok, receiver_ptr} <- Pointers.one(id: receiver.id) do
        Repo.insert(Claim.create_changeset(creator, provider_ptr, receiver_ptr, attrs))
      end
    end)
  end

  def update(%Claim{} = claim, %{} = _attrs) do
    {:ok, claim}
  end

  def soft_delete(%Claim{} = claim) do
    {:ok, claim}
  end

  def prepare_attrs(attrs) do
    attrs
    |> CommonsPub.Common.maybe_put(:action_id, Map.get(attrs, :action))
  end
end
