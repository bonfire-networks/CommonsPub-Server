# SPDX-License-Identifier: AGPL-3.0-only
defmodule CommonsPub.Feeds do
  alias CommonsPub.Feeds.{Feed, FeedSubscriptions, Queries}
  alias CommonsPub.Repo
  alias CommonsPub.Users.User

  def instance_outbox_id(), do: "10CA11NSTANCE00TB0XFEED1D0"
  def instance_inbox_id(), do: "10CA11NSTANCE1NB0XFEED1D00"

  def outbox_id(%{outbox_id: id}) when not is_nil(id) do
    id
  end

  def outbox_id(%{character: %{outbox_id: id}}) when not is_nil(id) do
    id
  end

  def outbox_id(%{character: _} = obj) do
    outbox_id(Repo.preload(obj, :character))
  end

  def outbox_id(_) do
    nil
  end

  def inbox_id(%{inbox_id: id}) when not is_nil(id) do
    id
  end

  def inbox_id(%{character: %{inbox_id: id}}) when not is_nil(id) do
    id
  end

  def inbox_id(%{character: _} = obj) do
    inbox_id(Repo.preload(obj, :character))
  end

  def inbox_id(_) do
    nil
  end

  @doc "Retrieves a single feed by arbitrary filters."
  def one(filters), do: Repo.single(Queries.query(Feed, filters))

  def many(filters \\ []), do: {:ok, Repo.all(Queries.query(Feed, filters))}

  def create(), do: Repo.insert(Feed.create_changeset())

  def update_by(%{}, filters, updates) do
    Repo.update_all(Queries.query(Feed, filters), set: updates)
  end

  def soft_delete_by(%{} = user, filters) do
    with {:ok, _} <-
           Repo.transact_with(fn ->
             {_, ids} =
               update_by(user, [{:deleted, false}, {:select, :id} | filters],
                 deleted_at: DateTime.utc_now()
               )

             chase_delete(user, ids)
           end),
         do: :ok
  end

  defp chase_delete(user, ids) do
    FeedSubscriptions.soft_delete_by(user, feed: ids)
  end
end
