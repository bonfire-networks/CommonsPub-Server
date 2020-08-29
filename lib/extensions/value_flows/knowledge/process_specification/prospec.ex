defmodule ValueFlows.Knowledge.ProcessSpecification do
  use Pointers.Pointable,
    otp_app: :moodle_net,
    source: "vf_process_spec",
    table_id: "ASPEC1F1CAT10NF0RPR0CESSES"

  import MoodleNet.Common.Changeset, only: [change_public: 1, change_disabled: 1]

  alias Ecto.Changeset
  alias MoodleNet.Users.User
  # alias MoodleNet.Actors.Actor
  # alias MoodleNet.Communities.Community
  alias ValueFlows.Knowledge.Action
  alias ValueFlows.Knowledge.ProcessSpecification
  alias Measurement.Measure

  @type t :: %__MODULE__{}

  pointable_schema do
    field(:name, :string)
    field(:note, :string)
    # belongs_to(:image, Content)

    field(:has_beginning, :utc_datetime_usec)
    field(:has_end, :utc_datetime_usec)

    field(:finished, :boolean, default: false)

    field(:classified_as, {:array, :string}, virtual: true)

    belongs_to(:context, Pointers.Pointer)

    # TODO
    # workingAgents: [Agent!]
    # basedOn: ProcessSpecification
    # nextProcesses: [ProcessSpecification!]
    # previousProcesses: [ProcessSpecification!]
    # intendedInputs(action: ID): [ProcessSpecification!]
    # intendedOutputs(action: ID): [ProcessSpecification!]
    # inputs(action: ID): [EconomicEvent!]
    # outputs(action: ID): [EconomicEvent!]
    # unplannedEconomicEvents(action: ID): [EconomicEvent!]
    # trace: [EconomicEvent!]
    # track: [EconomicEvent!]
    # plannedWithin: Plan
    # committedInputs(action: ID): [Commitment!]
    # committedOutputs(action: ID): [Commitment!]
    # nestedIn: Scenario

    # field(:deletable, :boolean) # TODO - virtual field? how is it calculated?

    belongs_to(:creator, User)

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
  @cast @required ++ ~w(note has_beginning has_end finished is_disabled image_id)a

  def create_changeset(
        %User{} = creator,
        %{id: _} = context,
        attrs
      ) do
    %ProcessSpecification{}
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
    %ProcessSpecification{}
    |> Changeset.cast(attrs, @cast)
    |> Changeset.validate_required(@required)
    |> Changeset.change(
      creator_id: creator.id,
      is_public: true
    )
    |> common_changeset()
  end

  def update_changeset(
        %ProcessSpecification{} = prospec,
        %{id: _} = context,
        attrs
      ) do
    prospec
    |> Changeset.cast(attrs, @cast)
    |> Changeset.change(context_id: context.id)
    |> common_changeset()
  end

  def update_changeset(%ProcessSpecification{} = prospec, attrs) do
    prospec
    |> Changeset.cast(attrs, @cast)
    |> common_changeset()
  end

  defp common_changeset(changeset) do
    changeset
    |> change_public()
    |> change_disabled()
  end

  def context_module, do: ValueFlows.Knowledge.ProcessSpecification.ProcessSpecifications

  def queries_module, do: ValueFlows.Knowledge.ProcessSpecification.Queries

  def follow_filters, do: [:default]
end
