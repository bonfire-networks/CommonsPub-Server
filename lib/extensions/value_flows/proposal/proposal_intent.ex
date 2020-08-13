defmodule ValueFlows.Proposal.ProposalIntent do
  use MoodleNet.Common.Schema

  alias Ecto.Changeset
  alias ValueFlows.Proposal
  alias ValueFlows.Planning.Intent

  table_schema "vf_proposal_intent" do
    # Note: allows null
    field(:reciprocal, :boolean)

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
