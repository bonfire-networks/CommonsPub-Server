defmodule MoodleNet.Comments.Comment do
  use MoodleNet.Common.Schema

  import MoodleNet.Common.Changeset,
    only: [meta_pointer_constraint: 1, change_public: 1, change_synced_timestamp: 3]

  alias Ecto.Changeset
  alias MoodleNet.Actors.Actor
  alias MoodleNet.Comments.{Comment, Thread}
  alias MoodleNet.Meta
  alias MoodleNet.Meta.Pointer

  meta_schema "mn_comment" do
    belongs_to(:creator, User)
    belongs_to(:thread, Thread)
    belongs_to(:reply_to, Comment)
    field(:canonical_url, :string)
    field(:content, :string)
    field(:is_local, :boolean)
    field(:is_hidden, :boolean, virtual: true)
    field(:hidden_at, :utc_datetime_usec)
    field(:is_public, :boolean, virtual: true)
    field(:published_at, :utc_datetime_usec)
    field(:deleted_at, :utc_datetime_usec)
    timestamps()
  end

  @create_cast ~w(canonical_url content is_local is_hidden is_public)a
  @create_required @create_cast

  @spec create_changeset(Pointer.t(), User.t(), Thread.t(), map) :: Changeset.t()
  def create_changeset(%Pointer{id: id} = pointer, creator, thread, attrs) do
    Meta.assert_points_to!(pointer, __MODULE__)

    %Comment{}
    |> Changeset.cast(attrs, @create_cast)
    |> Changeset.change(
      id: id,
      creator_id: creator.id,
      thread_id: thread.id,
      is_public: true
    )
    |> Changeset.validate_required(@create_required)
    |> common_changeset()
  end

  def reply_to_changeset(%Comment{} = comment, %Comment{} = reply_to) do
    Changeset.change(comment, :reply_to_id, reply_to.id)
  end

  @update_cast @create_cast

  @spec update_changeset(Comment.t(), map) :: Changeset.t()
  def update_changeset(%Comment{} = comment, attrs) do
    comment
    |> Changeset.cast(attrs, @update_cast)
    |> common_changeset()
  end

  defp common_changeset(changeset) do
    changeset
    |> change_public()
    |> change_synced_timestamp(:is_hidden, :hidden_at)
    |> meta_pointer_constraint()
  end
end
