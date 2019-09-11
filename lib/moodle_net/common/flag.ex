defmodule MoodleNet.Common.Flag do

  use Ecto.Schema
  alias MoodleNet.Meta.Pointer
  alias MoodleNet.Actors.Actor
  alias MoodleNet.Communities.Community

  @primary_key {:id, :binary_id, autogenerate: false}
  @foreign_key_type :binary_id
  schema "mn_flag" do
    belongs_to :flagged, Pointer
    belongs_to :flagger, Actor
    belongs_to :community, Community
    field :resolved_at, :utc_datetime
    field :reason, :string
    timestamps()
  end

  @create_cast ~w(flagged_id flagger_id community_id reason)a
  @create_required ~w(id flagged_id flagger_id reason)a
  def create_changeset(id, attrs) do
    %__MODULE__{id: id}
    |> Changeset.cast(attrs, @create_cast)
    |> Changeset.validate_required(@create_required)
    |> Changeset.foreign_key_constraint(:id)
    |> Changeset.foreign_key_constraint(:flagged_id)
    |> Changeset.foreign_key_constraint(:flagger_id)
    |> Changeset.foreign_key_constraint(:community_id)
  end

  def resolve_changeset(%__MODULE__{resolved_at: nil}=flag),
    do: Changeset.change(flag, resolved_at: DateTime.utc_now())

end
