defmodule ValueFlows.Proposal.ProposedIntent do
  use MoodleNet.Common.Schema

  alias Ecto.Changeset
  alias ValueFlows.Proposal
  alias ValueFlows.Planning.Intent

  table_schema "vf_proposed_intent" do
    # Note: allows null
    field(:reciprocal, :boolean)
    field(:deleted_at, :utc_datetime_usec)

    belongs_to(:publishes, Intent)
    belongs_to(:published_in, Proposal)
  end

  @cast ~w(reciprocal)

  def changeset(%Intent{} = publishes, %Proposal{} = published_in, %{} = attrs) do
    %__MODULE__{}
    |> Changeset.cast(attrs, @cast)
    |> Changeset.change(
      publishes_id: publishes.id,
      published_in_id: published_in.id,
    )
  end
end
