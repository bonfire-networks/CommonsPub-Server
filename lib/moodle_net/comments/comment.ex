defmodule MoodleNet.Comments.Comment do
  use MoodleNet.Common.Schema
  import MoodleNet.Common.Changeset, only: [meta_pointer_constraint: 1, change_public: 1]
  alias Ecto.Changeset
  alias MoodleNet.Actors.Actor
  alias MoodleNet.Common.Revision
  alias MoodleNet.Comments.{Comment, CommentRevision, CommentLatestRevision, Thread}
  alias MoodleNet.Meta
  alias MoodleNet.Meta.Pointer

  meta_schema "mn_comment" do
    belongs_to(:creator, Actor)
    belongs_to(:thread, Thread)
    # TODO: figure out if this is has_one or belongs_to
    belongs_to(:reply_to, Comment)
    has_many(:revisions, CommentRevision)
    has_one(:latest_revision, CommentLatestRevision)
    has_one(:current, through: [:latest_revision, :revision])
    field(:is_public, :boolean, virtual: true)
    field(:published_at, :utc_datetime_usec)
    field(:deleted_at, :utc_datetime_usec)
    timestamps()
  end

  @create_cast ~w()a
  @create_required @create_cast

  @spec create_changeset(Pointer.t(), Actor.t(), Thread.t(), map) :: Changeset.t()
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
    |> change_public()
    |> meta_pointer_constraint()
  end

  def reply_to_changeset(%Comment{} = comment, %Comment{} = reply_to) do
    Changeset.put_assoc(comment, :reply_to, reply_to)
  end

  @update_cast ~w(is_public)a

  @spec update_changeset(Comment.t(), map) :: Changeset.t()
  def update_changeset(%Comment{} = comment, attrs) do
    comment
    |> Changeset.cast(attrs, @update_cast)
    |> change_public()
    |> meta_pointer_constraint()
  end
end
