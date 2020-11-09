# SPDX-License-Identifier: AGPL-3.0-only
defmodule ValueFlows.Claim.Claims do
  alias CommonsPub.Repo
  alias CommonsPub.Users.User

  alias ValueFlows.Claim
  alias ValueFlows.Claim.Queries

  alias CommonsPub.Meta.Pointers

  import CommonsPub.Common, only: [maybe_put: 3]

  def one(filters), do: Repo.single(Queries.query(Claim, filters))

  def many(filters \\ []), do: {:ok, Repo.all(Queries.query(Claim, filters))}

  def preload_all(%Claim{} = claim) do
    Repo.preload(claim, [
      :creator,
      :provider,
      :receiver,
      :context,
      :resource_conforms_to,
      :resource_quantity,
      :effort_quantity,
      :triggered_by,
    ])
  end

  # TODO: change attributes and then pass to changeset, use preload for rest
  def create(%User{} = creator, %{id: _} = provider, %{id: _} = receiver, %{} = attrs) do
    Repo.transact_with(fn ->
      attrs = prepare_attrs(attrs)

      with {:ok, provider_ptr} <- Pointers.one(id: provider.id),
           {:ok, receiver_ptr} <- Pointers.one(id: receiver.id) do
        Claim.create_changeset(creator, provider_ptr, receiver_ptr, attrs)
        |> Claim.validate_required()
        |> Repo.insert()
        |> CommonsPub.Common.maybe_ok_error(&preload_all/1)
      end
    end)
  end

  def update(%Claim{} = claim, %{} = _attrs) do
    {:ok, claim}
  end

  def soft_delete(%Claim{} = claim) do
    {:ok, claim}
  end

  defp prepare_attrs(attrs) do
    attrs
    |> maybe_put(:action_id, Map.get(attrs, :action))
    |> maybe_put(:context_id,
      attrs |> Map.get(:in_scope_of) |> CommonsPub.Common.maybe(&List.first/1)
    )
    |> maybe_put(:resource_conforms_to_id, Map.get(attrs, :resource_conforms_to))
    |> maybe_put(:triggered_by_id, Map.get(attrs, :triggered_by))
  end
end
