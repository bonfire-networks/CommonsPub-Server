# SPDX-License-Identifier: AGPL-3.0-only
defmodule ValueFlows.Claim do
  use Pointers.Pointable,
    otp_app: :commons_pub,
    source: "vf_claim",
    table_id: "C0MM0NSPVBVA1VEF10WSC1A1MS"

  import CommonsPub.Common.Changeset, only: [change_public: 1, change_disabled: 1]

  alias Ecto.Changeset
  alias CommonsPub.Users.User

  alias ValueFlows.Knowledge.Action
  alias ValueFlows.Knowledge.ResourceSpecification
  alias ValueFlows.Observation.EconomicEvent
  alias ValueFlows.Observation.EconomicResource

  @type t :: %__MODULE__{}

  pointable_schema do
    field(:note, :string)
    field(:agreed_in, :string)
    field(:finished, :boolean)
    field(:created, :utc_datetime_usec)
    field(:due, :utc_datetime_usec)
    field(:resource_classified_as, {:array, :string})

    belongs_to(:action, Action, type: :string)
    belongs_to(:provider, Pointers.Pointer)
    belongs_to(:receiver, Pointers.Pointer)
    belongs_to(:resource_quantity, Measure, on_replace: :nilify)
    belongs_to(:effort_quantity, Measure, on_replace: :nilify)

    belongs_to(:resource_conforms_to, ResourceSpecification)
    belongs_to(:triggered_by, EconomicEvent)

    # a.k.a. in_scope_of
    belongs_to(:context, Pointers.Pointer)

    # not defined in spec, used internally
    belongs_to(:creator, User)
    field(:is_public, :boolean, virtual: true)
    field(:published_at, :utc_datetime_usec)
    field(:is_disabled, :boolean, virtual: true, default: false)
    field(:disabled_at, :utc_datetime_usec)
    field(:deleted_at, :utc_datetime_usec)

    timestamps(inserted_at: false)
  end

  @required ~w(action_id)a
  @cast @required ++
    ~w(note finished agreed_in created due resource_classified_as is_disabled)a

  def create_changeset(%User{} = creator, attrs) do
    %__MODULE__{}
    |> Changeset.cast(attrs, @cast)
    |> Changeset.change(
      creator_id: creator.id,
      is_public: true
    )
    |> common_changeset()
  end

  defp common_changeset(changeset) do
    changeset
    |> change_public()
    |> change_disabled()
  end
end
