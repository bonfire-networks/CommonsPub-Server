defmodule ValueFlows.Measurement.Measure do

  use MoodleNet.Common.Schema

  import MoodleNet.Common.Changeset, only: [change_public: 1, change_disabled: 1]

  alias Ecto.Changeset
  alias ValueFlows.Measurement.Measure
  alias MoodleNet.Users.User
  alias MoodleNet.Actors.Actor
  alias MoodleNet.Communities.Community
  alias ValueFlows.Measurement.Unit

  @type t :: %__MODULE__{}

  table_schema "vf_measure" do
    field :hasNumericalValue, :float

    field(:is_public, :boolean, virtual: true)
    field(:published_at, :utc_datetime_usec)
    field(:is_disabled, :boolean, virtual: true, default: false)
    field(:disabled_at, :utc_datetime_usec)
    field(:deleted_at, :utc_datetime_usec)

    belongs_to(:hasUnit, Unit)
    belongs_to(:creator, User)
    belongs_to(:community, Community)

    timestamps()
  end

  @required ~w(hasNumericalValue)a
  @cast @required ++ ~w()a

  def create_changeset(
        %User{} = creator,
        attrs
      ) do
    %ValueFlows.Measurement.Measure{}
    |> Changeset.cast(attrs, @cast)
    |> Changeset.validate_required(@required)
    |> Changeset.change(
      creator_id: creator.id
    )
    |> common_changeset()
  end

  def create_changeset(
      %User{} = creator,
      %Community{} = community,
      attrs
    ) do
  %ValueFlows.Measurement.Measure{}
  |> Changeset.cast(attrs, @cast)
  |> Changeset.validate_required(@required)
  |> Changeset.change(
    creator_id: creator.id,
    community_id: community.id,
    is_public: true
  )
  |> common_changeset()
  end

  def update_changeset(%ValueFlows.Measurement.Measure{} = measure, attrs) do
    measure
    |> Changeset.cast(attrs, @cast)
    |> common_changeset()
  end

  defp common_changeset(changeset) do
    changeset
    |> change_public()
    |> change_disabled()
  end

end
