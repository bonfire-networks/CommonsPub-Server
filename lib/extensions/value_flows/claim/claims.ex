# SPDX-License-Identifier: AGPL-3.0-only
defmodule ValueFlows.Claim.Claims do
  alias CommonsPub.Repo
  alias CommonsPub.Users.User

  alias ValueFlows.Claim
  alias ValueFlows.Claim.Queries

  def one(filters), do: Repo.single(Queries.query(Claim, filters))

  def many(filters \\ []), do: {:ok, Repo.all(Queries.query(Claim, filters))}

  def create(%User{} = creator, %{} = attrs) do
    Repo.transact_with(fn ->
      with {:ok, claim} <- Repo.insert(Claim.create_changeset(creator, attrs)) do
        {:ok, %{claim | creator: creator}}
      end
    end)
  end

  def update(%Claim{} = claim, %{} = attrs) do

  end

  def soft_delete(%Claim{} = claim) do

  end
end
