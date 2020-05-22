defmodule ValueFlows.Knowledge.Action do

  use MoodleNet.Common.Schema

  import MoodleNet.Common.Changeset, only: [change_public: 1, change_disabled: 1]
  # import Ecto.Enum

  alias Ecto.Changeset
  alias MoodleNet.Users.User
  alias ValueFlows.Knowledge.Action

  # defenum label_enum, work: 0, produce: 1, consume: 2, use: 3, consume: 4, transfer: 5

  @type t :: %__MODULE__{}

  table_schema "vf_action" do

    field(:label, :string) # A unique verb which defines the action.

    field(:input_output, :string) # Denotes if a process input or output, or not related to a process.
    # enum: "input", "output", "notApplicable"

    field(:pairs_with, :string) # The action that should be included on the other direction of the process, for example accept with modify.
    # possible values: "notApplicable" (null), or any of the actions (foreign key)
    # TODO: do we want to do this as an actual Action (optional)? In the VF spec they are NamedIndividuals defined in the spec, including "notApplicable".

    field(:resource_effect, :string) # The effect of an economic event on a resource, increment, decrement, no effect, or decrement resource and increment 'to' resource
    # enum: "increment", "decrement", "noEffect", "decrementIncrement"

    field(:note, :string) # description of the action (not part of VF)

    timestamps()
  end

  @required ~w(label resource_effect)a
  @cast @required ++ ~w(input_output pairs_with note)a

  def create_changeset(attrs) do
    %Action{}
    |> Changeset.cast(attrs, @cast)
    |> Changeset.validate_required(@required)
    |> common_changeset()
  end

  def update_changeset(%Action{} = action, attrs) do
    action
    |> Changeset.cast(attrs, @cast)
    |> common_changeset()
  end

  defp common_changeset(changeset) do
    changeset
  end

end
