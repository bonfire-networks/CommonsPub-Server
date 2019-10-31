defmodule MoodleNet.Uploads.Upload do
  use MoodleNet.Common.Schema
  import MoodleNet.Common.Changeset, only: [change_public: 1]

  alias Ecto.Changeset
  alias MoodleNet.Actors.Actor
  alias MoodleNet.Meta
  alias MoodleNet.Meta.Pointer

  @type t :: %__MODULE__{}

  standalone_schema "mn_upload" do
    # has_one(:preview, __MODULE__)
    belongs_to(:parent, Pointer)
    belongs_to(:uploader, Actor)
    field(:path, :string)
    field(:media_type, :string)
    field(:metadata, :map)
    field(:is_public, :boolean, virtual: true)
    field(:published_at, :utc_datetime_usec)
    timestamps()
  end

  @create_cast ~w(path media_type metadata is_public)a
  @create_required ~w(path media_type is_public)a

  def create_changeset(parent, uploader, attrs) do
    %__MODULE__{}
    |> Changeset.cast(attrs, @create_cast)
    |> Changeset.validate_required(@create_required)
    |> Changeset.put_assoc(:parent, parent)
    |> Changeset.put_assoc(:uploader, uploader)
    |> change_public()
  end

  def soft_delete_changeset(%__MODULE__{} = upload) do
    MoodleNet.Common.Changeset.soft_delete_changeset(upload)
  end
end
