defmodule ValueFlows.Proposal.Migrations do
  use Ecto.Migration
  # alias MoodleNet.Repo
  # alias Ecto.ULID
  import Pointers.Migration

  defp proposal_table(), do: ValueFlows.Proposal.__schema__(:source)
  defp proposed_intent_table(), do: ValueFlows.Proposal.ProposedIntent.__schema__(:source)

  def up do
    create_pointable_table(ValueFlows.Proposal) do
      add(:name, :string)
      add(:note, :text)

      add(:creator_id, references("mn_user", on_delete: :nilify_all))

      add(:eligible_location_id, references(:geolocation))

      # optional context as scope
      add(:context_id, weak_pointer(), null: true)

      add(:unit_based, :boolean, default: false)

      add(:has_beginning, :timestamptz)
      add(:has_end, :timestamptz)
      add(:created, :timestamptz)

      add(:published_at, :timestamptz)
      add(:deleted_at, :timestamptz)

      timestamps(inserted_at: false, type: :utc_datetime_usec)
    end

    create table(proposed_intent_table()) do
      # Note: null allowed
      add(:reciprocal, :boolean, null: true)
      add(:deleted_at, :timestamptz)
      add(:publishes_id, references("vf_intent", on_delete: :delete_all))
      add(:published_in_id, references(proposal_table(), on_delete: :delete_all))
    end
  end

  def down do
    drop_table(proposed_intent_table())
    drop_pointable_table(ValueFlows.Proposal)
  end
end
