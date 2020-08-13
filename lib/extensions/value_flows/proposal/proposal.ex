defmodule ValueFlows.Proposal do
  use Pointers.Pointable,
    otp_app: :moodle_net,
    source: "vf_proposal",
    table_id: "PR0P0SA11SMADE0FTW01NTENTS"

  import MoodleNet.Common.Changeset, only: [change_public: 1, change_disabled: 1]
  alias Ecto.Changeset
  alias MoodleNet.Users.User
  alias MoodleNet.Actors.Actor
  alias MoodleNet.Communities.Community
  alias ValueFlows.Proposal

  @type t :: %__MODULE__{}

  pointable_schema do
    field(:name, :string)
    field(:note, :string)
    field(:created, :utc_datetime_usec)
    field(:has_beginning, :utc_datetime_usec)
    field(:has_end, :utc_datetime_usec)
    field(:published_at, :utc_datetime_usec)

    field(:is_public, :boolean, virtual: true)

    belongs_to(:creator, User)
    belongs_to(:context, Pointers.Pointer)
    field(:unit_based, :boolean, default: false)
    belongs_to(:eligible_location, Geolocation)

    timestamps(inserted_at: false)
  end

  @required ~w(name is_public)a
  @cast @required ++ ~w(note eligible_location_id)a

  def create_changeset(
        %User{} = creator,
        %{id: _} = context,
        attrs
      ) do
    %Proposal{}
    |> Changeset.cast(attrs, @cast)
    |> Changeset.validate_required(@required)
    |> Changeset.change(
      creator_id: creator.id,
      context_id: context.id,
      is_public: true
    )
    |> common_changeset()
  end

  def create_changeset(
        %User{} = creator,
        attrs
      ) do
    %Proposal{}
    |> Changeset.cast(attrs, @cast)
    |> Changeset.validate_required(@required)
    |> Changeset.change(
      creator_id: creator.id,
      is_public: true
    )
    |> common_changeset()
  end

  def update_changeset(
        %Proposal{} = proposal,
        %{id: _} = context,
        attrs
      ) do
    proposal
    |> Changeset.cast(attrs, @cast)
    |> Changeset.change(context_id: context.id)
    |> common_changeset()
  end

  def update_changeset(%Proposal{} = proposal, attrs) do
    proposal
    |> Changeset.cast(attrs, @cast)
    |> common_changeset()
  end

  def change_eligible_location(changeset, %Geolocation{} = location) do
    Changeset.change(changeset,
      eligible_location: location,
      eligible_location_id: location.id
    )
  end

  defp common_changeset(changeset) do
    changeset
    |> change_public()
    |> Changeset.foreign_key_constraint(
      :eligible_location,
      name: :vf_proposal_eligible_location_id_fkey
    )
  end
end