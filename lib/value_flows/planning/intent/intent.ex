# relations TODO:
# SpatialThing WIP
# Action WIP
# AgentRelationship
# AgentRelationshipRole
# ResourceSpecification
# Proposal
# ProposedIntent
# ProposedTo(maybe?)
# Process
# ProcessSpecification

defmodule ValueFlows.Planning.Intent do

  use MoodleNet.Common.Schema

  import MoodleNet.Common.Changeset, only: [change_public: 1, change_disabled: 1]

  alias Ecto.Changeset
  alias MoodleNet.Users.User
  alias MoodleNet.Actors.Actor
  alias MoodleNet.Communities.Community
  alias ValueFlows.Knowledge.Action
  alias ValueFlows.Planning.Intent
  alias Measurement.Measure

  @type t :: %__MODULE__{}

  table_schema "vf_intent" do

    field(:name, :string)
    field(:note, :string)
    belongs_to(:image, Content)

    belongs_to(:provider, Pointer) # TODO - use pointer like context?
    belongs_to(:receiver, Pointer)

    belongs_to(:available_quantity, Measure, on_replace: :nilify)
    belongs_to(:resource_quantity, Measure, on_replace: :nilify)
    belongs_to(:effort_quantity, Measure, on_replace: :nilify)

    field(:has_beginning, :utc_datetime_usec)
    field(:has_end, :utc_datetime_usec)
    field(:has_point_in_time, :utc_datetime_usec)
    field(:due, :utc_datetime_usec)
    
    field(:resource_classified_as, {:array, :string}) # array of URI
    # belongs_to(:resource_conforms_to, ResourceSpecification)
    # belongs_to(:resource_inventoried_as, EconomicResource)

    belongs_to(:at_location, Geolocation)

    belongs_to(:action, Action)

    # belongs_to(:input_of, Process)
    # belongs_to(:output_of, Process)

    # belongs_to(:agreed_in, Agreement)

    # inverse relationships 
    # has_many(:published_in, ProposedIntent)
    # has_many(:satisfied_by, Satisfaction)

    belongs_to(:creator, User)
    belongs_to(:context, Pointer)

    field(:finished, :boolean, default: false)
    # field(:deletable, :boolean) # TODO - virtual field? how is it calculated?

    field(:is_public, :boolean, virtual: true)
    field(:published_at, :utc_datetime_usec)
    field(:is_disabled, :boolean, virtual: true, default: false)
    field(:disabled_at, :utc_datetime_usec)
    field(:deleted_at, :utc_datetime_usec)

    timestamps()
  end


  @required ~w(name is_public)a
  @cast @required ++ ~w(note at_location_id is_disabled)a

  def create_changeset(
        %User{} = creator,
        %{id: _} = context,
        attrs
      ) do
    %Intent{}
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
    %Intent{}
    |> Changeset.cast(attrs, @cast)
    |> Changeset.validate_required(@required)
    |> Changeset.change(
      creator_id: creator.id,
      is_public: true
    )
    |> common_changeset()
  end

  def update_changeset(
    %Intent{} = intent,
    %{id: _} = context,
    attrs
  ) do
    intent
    |> Changeset.cast(attrs, @cast)
    |> Changeset.change(context_id: context.id)
    |> common_changeset()
  end

  def update_changeset(%Intent{} = intent, attrs) do
    intent
    |> Changeset.cast(attrs, @cast)
    |> common_changeset()
  end

  def change_measures(changeset, measures) when is_map(measures) do
    Enum.reduce(measures, changeset, fn {field_name, measure}, c ->
      Changeset.put_assoc(c, field_name, measure)
    end)
  end

  def change_at_location(changeset, %Geolocation{} = location) do
    Changeset.change(changeset,
      at_location: location,
      at_location_id: location.id
    )
  end

  defp common_changeset(changeset) do
    changeset
    |> change_public()
    |> change_disabled()
    |> Changeset.foreign_key_constraint(
      :at_location_id, name: :vf_intent_at_location_id_fkey
    )
  end
end
