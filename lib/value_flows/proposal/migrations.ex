defmodule ValueFlows.Proposal.Migrations do
  use Ecto.Migration
  alias MoodleNet.Repo
  alias Ecto.ULID
  import Pointers.Migration

  defp proposal_table(), do: ValueFlows.Proposal.__schema__(:source)

  def up do
    create_pointable_table(proposal_table(), "PR0P0SA11SMADE0FTW01NTENTS") do
      add(:name, :string)
      add(:note, :text)

      add(:creator_id, references("mn_user", on_delete: :nilify_all))

      # add(:image_id, references(:mn_content))

      # belongs_to(:provider, Pointer) # TODO - use pointer like context?
      # belongs_to(:receiver, Pointer)
      # add(:provider_id, references("mn_pointer", on_delete: :nilify_all))
      # add(:receiver_id, references("mn_pointer", on_delete: :nilify_all))

      # add(:available_quantity_id, references("measurement_measure", on_delete: :nilify_all))
      # add(:resource_quantity_id, references("measurement_measure", on_delete: :nilify_all))
      # add(:effort_quantity_id, references("measurement_measure", on_delete: :nilify_all))

      # array of URI
      # add(:resource_classified_as, {:array, :string})

      # # belongs_to(:resource_conforms_to, ResourceSpecification)
      # # belongs_to(:resource_inventoried_as, EconomicResource)

      add(:eligible_location_id, references(:geolocation))

      # optional context as scope
      add(:context_id, weak_pointer(), null: true)

      add(:unit_based, :boolean, default: false)

      # # field(:deletable, :boolean) # TODO - virtual field? how is it calculated?

      # belongs_to(:input_of, Process)
      # belongs_to(:output_of, Process)

      # belongs_to(:agreed_in, Agreement)

      # inverse relationships
      # has_many(:published_in, ProposedIntent)
      # has_many(:satisfied_by, Satisfaction)

      add(:has_beginning, :timestamptz)
      add(:has_end, :timestamptz)
      add(:created, :timestamptz)

      add(:published_at, :timestamptz)
      add(:deleted_at, :timestamptz)
      add(:disabled_at, :timestamptz)

      timestamps(type: :utc_datetime_usec)
    end
  end

  def down do
    drop_pointable_table(proposal_table(), "PR0P0SA11SMADE0FTW01NTENTS")
  end
end
