# SPDX-License-Identifier: AGPL-3.0-only
defmodule CommonsPub.Activities.Activity do
  use Bonfire.Repo.Schema

  import Bonfire.Repo.Changeset, only: [change_public: 1]
  alias CommonsPub.Activities
  alias CommonsPub.Activities.Activity
  alias CommonsPub.Feeds.FeedActivity
  alias CommonsPub.Users.User
  alias Pointers.Pointer
  alias Ecto.Changeset

  @type t :: %Activity{}

  table_schema "mn_activity" do
    belongs_to(:creator, User)
    belongs_to(:context, Pointer)
    has_many(:feed_activities, FeedActivity)
    field(:canonical_url, :string)
    field(:verb, :string)
    field(:is_local, :boolean)
    field(:is_public, :boolean, virtual: true)
    field(:published_at, :utc_datetime_usec)
    field(:deleted_at, :utc_datetime_usec)
    timestamps()
  end

  @required ~w(verb is_local)a
  @cast @required ++ ~w(canonical_url is_public)a

  def create_changeset(%User{id: creator_id}, %{id: context_id}, %{} = attrs)
      when is_binary(creator_id) and is_binary(context_id) do
    %Activity{}
    |> Changeset.cast(attrs, @cast)
    |> Changeset.change(
      creator_id: creator_id,
      context_id: context_id,
      is_public: true
    )
    |> Changeset.validate_required(@required)
    |> common_changeset()
  end

  def update_changeset(%Activity{} = activity, attrs) do
    activity
    |> Changeset.cast(attrs, @cast)
    |> common_changeset()
  end

  defp common_changeset(changeset) do
    changeset
    |> change_public()
  end

  ### behaviour callbacks

  def context_module, do: Activities

  def queries_module, do: Activities.Queries

  def follow_filters, do: []

  def type, do: :activity
end
