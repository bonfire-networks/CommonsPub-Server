# SPDX-License-Identifier: AGPL-3.0-only
defmodule CommonsPub.Feeds.Feed do
  use CommonsPub.Repo.Schema
  alias Ecto.Changeset
  alias CommonsPub.Feeds

  table_schema "mn_feed" do
    field(:deleted_at, :utc_datetime_usec)
  end

  @doc "Creates a new feed in the database"
  def create_changeset() do
    %__MODULE__{}
    |> Changeset.cast(%{}, [])
  end

  ### behaviour callbacks

  def context_module, do: Feeds

  def queries_module, do: Feeds.Queries

  def follow_filters, do: []
end
