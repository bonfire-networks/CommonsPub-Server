defmodule ValueFlows.Observation.EconomicResource do
  use Pointers.Pointable,
    otp_app: :commons_pub,
    source: "vf_resource",
    table_id: "AN0BSERVEDANDVSEFV1RES0VRC"

  import CommonsPub.Common.Changeset, only: [change_public: 1, change_disabled: 1]
  alias Ecto.Changeset

  alias CommonsPub.Users.User

  alias Measurement.Measure
  alias Measurement.Unit

  alias ValueFlows.Knowledge.Action
  alias ValueFlows.Knowledge.ResourceSpecification
  alias ValueFlows.Knowledge.ProcessSpecification

  alias ValueFlows.Observation.EconomicResource

  @type t :: %__MODULE__{}

  pointable_schema do
    field(:name, :string)
    field(:note, :string)
    field(:tracking_identifier, :string)

    belongs_to(:image, Content)

    belongs_to(:conforms_to, ResourceSpecification)

    belongs_to(:current_location, Geolocation)

    belongs_to(:contained_in, EconomicResource)

    belongs_to(:state, Action, type: :string)

    belongs_to(:primary_accountable, Pointers.Pointer)

    belongs_to(:accounting_quantity, Measure, on_replace: :nilify)
    belongs_to(:onhand_quantity, Measure, on_replace: :nilify)

    belongs_to(:unit_of_effort, Unit, on_replace: :nilify)

    # belongs_to(:stage, ProcessSpecification)

    # TODO relations:
    # lot: ProductBatch

    belongs_to(:creator, User)

    # field(:deletable, :boolean) # TODO - virtual field? how is it calculated?

    field(:is_public, :boolean, virtual: true)
    field(:published_at, :utc_datetime_usec)
    field(:is_disabled, :boolean, virtual: true, default: false)
    field(:disabled_at, :utc_datetime_usec)
    field(:deleted_at, :utc_datetime_usec)

    many_to_many(:tags, CommonsPub.Tag.Taggable,
      join_through: "tags_things",
      unique: true,
      join_keys: [pointer_id: :id, tag_id: :id],
      on_replace: :delete
    )

    timestamps(inserted_at: false)
  end

  @required ~w(name is_public)a
  @cast @required ++ ~w(note tracking_identifier current_location_id is_disabled image_id)a

  def create_changeset(
        %User{} = creator,
        attrs
      ) do
    %EconomicResource{}
    |> Changeset.cast(attrs, @cast)
    |> Changeset.validate_required(@required)
    |> Changeset.change(
      creator_id: creator.id,
      is_public: true
    )
    |> common_changeset()
  end

  def update_changeset(%EconomicResource{} = resource, attrs) do
    resource
    |> Changeset.cast(attrs, @cast)
    |> common_changeset()
  end

  def change_primary_accountable(changeset, %{id: _} = primary_accountable) do
    Changeset.change(changeset,
      primary_accountable: primary_accountable,
      primary_accountable_id: primary_accountable.id
    )
  end

  def change_state_action(changeset, %Action{} = state) do
    Changeset.change(changeset,
      state_id: state.id
    )
  end

  def change_stage_process_spec(changeset, %ProcessSpecification{} = stage) do
    Changeset.change(changeset,
      stage: stage,
      stage: stage.id
    )
  end

  def change_current_location(changeset, %Geolocation{} = location) do
    Changeset.change(changeset,
      current_location: location,
      current_location_id: location.id
    )
  end

  def change_conforms_to_resource_spec(changeset, %ResourceSpecification{} = conforms_to) do
    Changeset.change(changeset,
      conforms_to: conforms_to,
      conforms_to_id: conforms_to.id
    )
  end

  def change_contained_in_resource(changeset, %EconomicResource{} = contained_in) do
    Changeset.change(changeset,
      contained_in: contained_in,
      contained_in_id: contained_in.id
    )
  end

  def change_unit_of_effort(changeset, %Unit{} = unit_of_effort) do
    Changeset.change(changeset,
      unit_of_effort: unit_of_effort,
      unit_of_effort_id: unit_of_effort.id
    )
  end

  def change_measures(changeset, %{} = attrs) do
    measures = Map.take(attrs, measure_fields())

    Enum.reduce(measures, changeset, fn {field_name, measure}, c ->
      Changeset.put_assoc(c, field_name, measure)
    end)
  end

  def measure_fields do
    [:onhand_quantity, :accounting_quantity]
  end

  defp common_changeset(changeset) do
    changeset
    |> change_public()
    |> change_disabled()
  end

  def context_module, do: ValueFlows.Observation.EconomicResource.EconomicResources

  def queries_module, do: ValueFlows.Observation.EconomicResource.Queries

  def follow_filters, do: [:default]
end
