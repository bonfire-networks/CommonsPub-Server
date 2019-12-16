defmodule MoodleNet.Comments.Thread do
  use MoodleNet.Common.Schema

  import MoodleNet.Common.Changeset, only: [change_synced_timestamp: 3]

  alias Ecto.Changeset
  alias MoodleNet.Comments.{Thread, ThreadFollowerCount}
  alias MoodleNet.Feeds.Feed
  alias MoodleNet.Meta
  alias MoodleNet.Meta.Pointer
  alias MoodleNet.Users.User

  table_schema "mn_thread" do
    belongs_to(:creator, User)
    belongs_to(:context, Pointer)
    belongs_to(:outbox, Feed)
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
    has_one(:follower_count, ThreadFollowerCount)
    timestamps()
  end

  @required ~w(is_local outbox_id)a
  @cast @required ++ ~w(canonical_url is_locked is_hidden)a

  def create_changeset(%User{id: creator_id}, %{id: context_id}, attrs) do
    %Thread{}
    |> Changeset.cast(attrs, @cast)
    |> Changeset.change(
      creator_id: creator_id,
      context_id: context_id
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
    |> change_synced_timestamp(:is_locked, :published_at)
  end
end
