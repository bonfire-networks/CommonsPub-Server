defmodule ValueFlows.Knowledge.Action do

  use MoodleNet.Common.Schema

  import MoodleNet.Common.Changeset, only: [change_public: 1, change_disabled: 1]
  # import Ecto.Enum

  alias Ecto.Changeset
  alias MoodleNet.Users.User
  alias MoodleNet.Actors.Actor
  alias MoodleNet.Communities.Community
  alias ValueFlows.Knowledge.Action

  # defenum label_enum, work: 0, produce: 1, consume: 2, use: 3, consume: 4, transfer: 5

  @type t :: %__MODULE__{}

  table_schema "vf_actions" do
    field(:input_output, :string)
    field(:label, :string)
    field(:pairs_with, :string)
    field(:resource_effect, :string)

    timestamps()
  end

  @required ~w(label resource_effect)a
  @cast @required ++ ~w(input_output pairs_with)a

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
    |> change_public()
    |> change_disabled()
  end

end
