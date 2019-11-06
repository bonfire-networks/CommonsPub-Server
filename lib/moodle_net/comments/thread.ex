defmodule MoodleNet.Comments.Thread do
  use MoodleNet.Common.Schema
  import MoodleNet.Common.Changeset, only: [change_public: 1]
  alias Ecto.Changeset
  alias MoodleNet.Actors.Actor
  alias MoodleNet.Comments.Thread
  alias MoodleNet.Meta
  alias MoodleNet.Meta.Pointer

  standalone_schema "mn_thread" do
    belongs_to(:creator, Actor)
    belongs_to(:parent, Pointer)
    field(:is_public, :boolean, virtual: true)
    field(:published_at, :utc_datetime_usec)
    field(:deleted_at, :utc_datetime_usec)
    timestamps()
  end

  @create_cast ~w()a
  @create_required @create_cast

  def create_changeset(%Pointer{id: id} = pointer, %Pointer{} = parent, %Actor{} = creator, attrs) do
    Meta.assert_points_to!(pointer, __MODULE__)
    %Thread{}
    |> Changeset.cast(attrs, @create_cast)
    |> Changeset.change(
      id: id,
      creator_id: creator.id,
      parent_id: parent.id,
      is_public: true
    )
    |> Changeset.validate_required(@create_required)
    |> change_public()
  end

  @update_cast ~w()a

  def update_changeset(%Thread{} = thread, attrs) do
    thread
    |> Changeset.cast(attrs, @update_cast)
    |> change_public()
  end
end
