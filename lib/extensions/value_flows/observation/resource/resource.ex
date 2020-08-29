defmodule ValueFlows.Observation.EconomicResource do
  use Pointers.Pointable,
    otp_app: :moodle_net,
    source: "vf_resource",
    table_id: "AN0BSERVEDANDVSEFV1RES0VRC"

  import MoodleNet.Common.Changeset, only: [change_public: 1, change_disabled: 1]
  alias Ecto.Changeset

  alias MoodleNet.Users.User

  alias Measurement.Measure
  alias Measurement.Unit

  alias ValueFlows.Knowledge.Action
  alias ValueFlows.Observation.EconomicResource

  @type t :: %__MODULE__{}

  pointable_schema do
    field(:name, :string)
    field(:note, :string)
    field(:tracking_identifier, :string)

    belongs_to(:image, Content)

    belongs_to(:conforms_to, ResourceSpecification)

    # array of URI
    field(:classified_as, {:array, :string}, virtual: true)

    belongs_to(:current_location, Geolocation)

    belongs_to(:contained_in, EconomicResource)

    belongs_to(:state, Action, type: :string)

    belongs_to(:primary_accountable, Pointers.Pointer)

    belongs_to(:accounting_quantity, Measure, on_replace: :nilify)
    belongs_to(:onhand_quantity, Measure, on_replace: :nilify)

    belongs_to(:unit_of_effort, Unit, on_replace: :nilify)

    belongs_to(:stage, ProcessSpecification)

    # TODO relations:
    # lot: ProductBatch

    belongs_to(:creator, User)
    belongs_to(:context, Pointers.Pointer)

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
        %Action{} = state,
        %{id: _} = context,
        attrs
      ) do
    %EconomicResource{}
    |> Changeset.cast(attrs, @cast)
    |> Changeset.validate_required(@required)
    |> Changeset.change(
      creator_id: creator.id,
      context_id: context.id,
      # TODO: move state to context and validate that it's a valid state
      state_id: state.id,
      is_public: true
    )
    |> common_changeset()
  end

  def create_changeset(
        %User{} = creator,
        %Action{} = state,
        attrs
      ) do
    %EconomicResource{}
    |> Changeset.cast(attrs, @cast)
    |> Changeset.validate_required(@required)
    |> Changeset.change(
      creator_id: creator.id,
      state_id: state.id,
      is_public: true
    )
    |> common_changeset()
  end

  def update_changeset(
        %EconomicResource{} = resource,
        %{id: _} = context,
        attrs
      ) do
    resource
    |> Changeset.cast(attrs, @cast)
    |> Changeset.change(context_id: context.id)
    |> common_changeset()
  end

  def update_changeset(%EconomicResource{} = resource, attrs) do
    resource
    |> Changeset.cast(attrs, @cast)
    |> common_changeset()
  end

  def measure_fields do
    [:onhand_quantity, :accounting_quantity]
  end

  def change_measures(changeset, %{} = attrs) do
    measures = Map.take(attrs, measure_fields())

    Enum.reduce(measures, changeset, fn {field_name, measure}, c ->
      Changeset.put_assoc(c, field_name, measure)
    end)
  end

  def change_current_location(changeset, %Geolocation{} = location) do
    Changeset.change(changeset,
      current_location: location,
      current_location_id: location.id
    )
  end

  def change_action(changeset, %Action{} = state) do
    Changeset.change(changeset, state_id: state.id)
  end

  def change_primary_accountable(changeset, %{id: _} = primary_accountable) do
    Changeset.change(changeset, primary_accountable_id: primary_accountable.id)
  end

  def change_receiver(changeset, %{id: _} = receiver) do
    Changeset.change(changeset, receiver_id: receiver.id)
  end

  defp common_changeset(changeset) do
    changeset
    |> change_public()
    |> change_disabled()
    |> Changeset.foreign_key_constraint(
      :current_location_id,
      name: :vf_resource_current_location_id_fkey
    )
  end

  def context_module, do: ValueFlows.Observation.EconomicResource.EconomicResources

  def queries_module, do: ValueFlows.Observation.EconomicResource.Queries

  def follow_filters, do: [:default]
end
