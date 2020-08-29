defmodule ValueFlows.Knowledge.ResourceSpecification do
  use Pointers.Pointable,
    otp_app: :moodle_net,
    source: "vf_resource_spec",
    table_id: "SPEC1F1CAT10NK1ND0FRES0VRC"

  import MoodleNet.Common.Changeset, only: [change_public: 1, change_disabled: 1]

  alias Ecto.Changeset
  alias MoodleNet.Users.User
  # alias MoodleNet.Actors.Actor
  # alias MoodleNet.Communities.Community
  alias ValueFlows.Knowledge.Action
  alias ValueFlows.Knowledge.ResourceSpecification
  alias Measurement.Unit

  @type t :: %__MODULE__{}

  pointable_schema do
    field(:name, :string)
    field(:note, :string)

    belongs_to(:image, Content)

    # array of URI
    field(:resource_classified_as, {:array, :string}, virtual: true)

    belongs_to(:default_unit_of_effort, Unit, on_replace: :nilify)

    belongs_to(:creator, User)
    belongs_to(:context, Pointers.Pointer)

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
  @cast @required ++ ~w(note is_disabled image_id)a

  def create_changeset(
        %User{} = creator,
        %{id: _} = context,
        attrs
      ) do
    %ResourceSpecification{}
    |> Changeset.cast(attrs, @cast)
    |> Changeset.validate_required(@required)
    |> Changeset.change(
      creator_id: creator.id,
      default_unit_of_effort_id: Map.get(attrs, :default_unit_of_effort),
      context_id: context.id,
      is_public: true
    )
    |> common_changeset()
  end

  def create_changeset(
        %User{} = creator,
        attrs
      ) do
    %ResourceSpecification{}
    |> Changeset.cast(attrs, @cast)
    |> Changeset.validate_required(@required)
    |> Changeset.change(
      creator_id: creator.id,
      default_unit_of_effort_id: Map.get(attrs, :default_unit_of_effort),
      is_public: true
    )
    |> common_changeset()
  end

  def update_changeset(
        %ResourceSpecification{} = respec,
        %{id: _} = context,
        attrs
      ) do
    respec
    |> Changeset.cast(attrs, @cast)
    |> Changeset.change(
      context_id: context.id,
      default_unit_of_effort_id: Map.get(attrs, :default_unit_of_effort)
    )
    |> common_changeset()
  end

  def update_changeset(%ResourceSpecification{} = respec, attrs) do
    respec
    |> Changeset.cast(attrs, @cast)
    |> Changeset.change(default_unit_of_effort_id: Map.get(attrs, :default_unit_of_effort))
    |> common_changeset()
  end

  defp common_changeset(changeset) do
    changeset
    |> change_public()
    |> change_disabled()
  end

  def context_module, do: ValueFlows.Knowledge.ResourceSpecification.ResourceSpecifications

  def queries_module, do: ValueFlows.Knowledge.ResourceSpecification.Queries

  def follow_filters, do: [:default]
end
