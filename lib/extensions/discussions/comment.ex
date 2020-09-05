# SPDX-License-Identifier: AGPL-3.0-only
defmodule CommonsPub.Threads.Comment do
  use CommonsPub.Common.Schema

  import CommonsPub.Common.Changeset,
    only: [change_public: 1, change_synced_timestamp: 3, cast_object: 1]

  alias Ecto.Changeset
  alias CommonsPub.Threads
  alias CommonsPub.Threads.{Comment, Thread}
  alias CommonsPub.Users.User

  table_schema "mn_comment" do
    belongs_to(:creator, User)
    belongs_to(:thread, Thread)
    belongs_to(:reply_to, Comment)
    field(:canonical_url, :string)
    field(:name, :string)
    field(:content, :string)
    field(:is_local, :boolean)
    field(:is_hidden, :boolean, virtual: true)
    field(:hidden_at, :utc_datetime_usec)
    field(:is_public, :boolean, virtual: true)
    field(:published_at, :utc_datetime_usec)
    field(:deleted_at, :utc_datetime_usec)
    timestamps()
  end

  @required ~w(content is_local creator_id)a
  @cast @required ++ ~w(name canonical_url is_hidden is_public reply_to_id)a

  @spec create_changeset(User.t(), Thread.t(), map) :: Changeset.t()
  def create_changeset(creator, thread, attrs) do
    %Comment{}
    |> Changeset.cast(attrs, @cast)
    |> cast_object()
    |> Changeset.change(
      creator_id: creator.id,
      thread_id: thread.id,
      is_public: true
    )
    |> Changeset.validate_required(@required)
    |> common_changeset()
  end

  def reply_to_changeset(%Changeset{} = changeset, %Comment{} = reply_to) do
    Changeset.put_change(changeset, :reply_to_id, reply_to.id)
  end

  @spec update_changeset(%Comment{}, map) :: Changeset.t()
  def update_changeset(%Comment{} = comment, attrs) do
    comment
    |> Changeset.cast(attrs, @cast)
    |> common_changeset()
  end

  defp common_changeset(changeset) do
    changeset
    |> change_public()
    |> change_synced_timestamp(:is_hidden, :hidden_at)
  end

  ### behaviour callbacks

  def context_module, do: Threads.Comments

  def queries_module, do: Threads.CommentsQueries

  def follow_filters, do: []
end
