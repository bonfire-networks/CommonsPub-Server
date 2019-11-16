defmodule MoodleNet.Comments.Thread do
  use MoodleNet.Common.Schema

  import MoodleNet.Common.Changeset,
    only: [change_synced_timestamp: 3, meta_pointer_constraint: 1]

  alias Ecto.Changeset
  alias MoodleNet.Comments.{Thread, ThreadFollowerCount}
  alias MoodleNet.Meta
  alias MoodleNet.Meta.Pointer
  alias MoodleNet.Users.User

  meta_schema "mn_thread" do
    belongs_to(:creator, User)
    belongs_to(:context, Pointer)
    field(:canonical_url, :string)
    field(:is_locked, :boolean, virtual: true)
    field(:locked_at, :utc_datetime_usec)
    field(:is_hidden, :boolean, virtual: true)
    field(:hidden_at, :utc_datetime_usec)
    field(:is_local, :boolean)
    field(:deleted_at, :utc_datetime_usec)
    has_one(:follower_count, ThreadFollowerCount)
    timestamps()
  end

  @required ~w(is_local)a
  @cast @required ++ ~w(canonical_url is_locked is_hidden)a

  def create_changeset(%Pointer{id: id} = pointer, %Pointer{} = context, %User{} = creator, attrs) do
    Meta.assert_points_to!(pointer, __MODULE__)

    %Thread{}
    |> Changeset.cast(attrs, @cast)
    |> Changeset.change(
      id: id,
      creator_id: creator.id,
      context_id: context.id
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
    |> meta_pointer_constraint()
  end
end
