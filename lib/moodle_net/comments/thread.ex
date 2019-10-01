defmodule MoodleNet.Comments.Thread do
  use MoodleNet.Common.Schema
  import MoodleNet.Common.Changeset, only: [change_public: 1]
  alias Ecto.Changeset
  alias MoodleNet.Comments.Thread
  alias MoodleNet.Meta
  alias MoodleNet.Meta.Pointer

  standalone_schema "mn_thread" do
    belongs_to :parent, Pointer
    field(:is_public, :boolean, virtual: true)
    field(:published_at, :utc_datetime_usec)
    field(:deleted_at, :utc_datetime_usec)
    timestamps()
  end

  @create_cast ~w(is_public)a
  @create_required @create_cast

  def create_changeset(%Pointer{} = parent, attrs) do
    %Thread{}
    |> Changeset.cast(attrs, @create_cast)
    |> Changeset.validate_required(@create_required)
    |> Changeset.put_assoc(:parent, parent)
    |> change_public()
  end

  @update_cast ~w(is_public)a

  def update_changeset(%Thread{} = thread, attrs) do
    thread
    |> Changeset.cast(attrs, @update_cast)
    |> change_public()
  end
end
