defmodule ValueFlows.Proposal do
  @moduledoc """
  Schema for proposal, using `Pointers.Pointable`
  """
  use Pointers.Pointable,
    otp_app: :commons_pub,
    source: "vf_proposal",
    table_id: "PR0P0SA11SMADE0FTW01NTENTS"

  import CommonsPub.Common.Changeset, only: [change_public: 1, claim_changeset: 3]
  alias Ecto.Changeset
  alias CommonsPub.Users.User
  #
  # alias CommonsPub.Communities.Community
  alias ValueFlows.Proposal
  alias ValueFlows.Planning.Intent

  @type t :: %__MODULE__{}

  pointable_schema do
    field(:name, :string)
    field(:note, :string)
    field(:created, :utc_datetime_usec)
    field(:has_beginning, :utc_datetime_usec)
    field(:has_end, :utc_datetime_usec)
    field(:published_at, :utc_datetime_usec)
    field(:deleted_at, :utc_datetime_usec)

    field(:is_public, :boolean, virtual: true)
    field(:unit_based, :boolean, default: false)

    belongs_to(:creator, User)
    belongs_to(:context, Pointers.Pointer)
    belongs_to(:eligible_location, Geolocation)

    many_to_many(:publishes, Intent, join_through: ProposedIntent)
    many_to_many(:proposed_to, Pointers.Pointer, join_through: ProposedTo)

    timestamps(inserted_at: false)
  end

  @required ~w(name is_public)a
  @cast @required ++ ~w(note has_beginning has_end unit_based eligible_location_id)a

  def create_changeset(
        %User{} = creator,
        %{id: _} = context,
        attrs
      ) do
    %Proposal{}
    |> Changeset.cast(attrs, @cast)
    |> Changeset.validate_required(@required)
    |> Changeset.change(
      created: DateTime.utc_now(),
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
      created: DateTime.utc_now(),
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
