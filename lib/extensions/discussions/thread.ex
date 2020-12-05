# SPDX-License-Identifier: AGPL-3.0-only
defmodule CommonsPub.Threads.Thread do
  use CommonsPub.Repo.Schema

  import CommonsPub.Repo.Changeset, only: [change_synced_timestamp: 3]

  alias Ecto.Changeset
  alias CommonsPub.Follows.FollowerCount
  alias CommonsPub.Feeds.Feed
  # alias Pointers.Pointer
  alias CommonsPub.Threads
  alias CommonsPub.Threads.{LastComment, Comment, Thread}
  alias CommonsPub.Users.User

  table_schema "mn_thread" do
    field(:name, :string)
    belongs_to(:creator, User)
    belongs_to(:context, Pointers.Pointer)
    belongs_to(:outbox, Feed)
    has_many(:comments, Comment)
    has_one(:follower_count, FollowerCount, foreign_key: :context_id)
    has_one(:first_comment, FirstComment)
    has_one(:last_comment, LastComment)
    field(:ctx, :any, virtual: true)
    field(:canonical_url, :string)
    field(:is_public, :boolean, virtual: true)
    field(:published_at, :utc_datetime_usec)
    field(:is_locked, :boolean, virtual: true)
    field(:locked_at, :utc_datetime_usec)
    field(:is_hidden, :boolean, virtual: true)
    field(:hidden_at, :utc_datetime_usec)
    field(:is_local, :boolean)
    field(:deleted_at, :utc_datetime_usec)
    timestamps()
  end

  @required ~w(is_local outbox_id)a
  @cast @required ++ ~w(name canonical_url is_locked is_hidden)a

  def create_changeset(creator, attrs, context \\ nil)

  def create_changeset(%User{id: creator_id}, attrs, %{id: context_id}) do
    %Thread{}
    |> Changeset.cast(attrs, @cast)
    |> Changeset.change(
      creator_id: creator_id,
      context_id: context_id,
      is_public: true
    )
    |> Changeset.validate_required(@required)
    |> common_changeset()
  end

  def create_changeset(%User{id: creator_id}, attrs, _) do
    %Thread{}
    |> Changeset.cast(attrs, @cast)
    |> Changeset.change(
      creator_id: creator_id,
      is_public: true
    )
    |> Changeset.validate_required(@required)
    |> common_changeset()
  end

  def update_changeset(%Thread{} = thread, attrs) do
    thread
    |> Changeset.cast(attrs, @cast)
    |> common_changeset()
  end

  defp common_changeset(changeset) do
    changeset
    |> change_synced_timestamp(:is_hidden, :hidden_at)
    |> change_synced_timestamp(:is_locked, :locked_at)
    |> change_synced_timestamp(:is_public, :published_at)
  end

  ### behaviour callbacks

  def context_module, do: Threads

  def queries_module, do: Threads.Queries

  def follow_filters, do: []
end
