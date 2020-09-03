defmodule ValueFlows.Observation.EconomicResource.Migrations do
  use Ecto.Migration
  # alias CommonsPub.Repo
  # alias Ecto.ULID
  import Pointers.Migration

  alias ValueFlows.Knowledge.ResourceSpecification
  alias ValueFlows.Knowledge.ProcessSpecification
  alias ValueFlows.Observation.EconomicResource
  # alias ValueFlows.Observation.EconomicEvent
  # alias ValueFlows.Observation.Process

  # defp resource_table(), do: EconomicResource.__schema__(:source)

  def up do
    create_pointable_table(ValueFlows.Observation.EconomicResource) do
      add(:name, :string)
      add(:note, :text)
      add(:tracking_identifier, :text)

      add(:image_id, references(:mn_content))

      add(:conforms_to_id, weak_pointer(ResourceSpecification), null: true)

      # add(:resource_classified_as, {:array, :string}, virtual: true)

      add(:current_location_id, references(:geolocation))

      add(:contained_in_id, weak_pointer(EconomicResource), null: true)

      add(:state_id, :string)

      # usually linked to Agent
      add(:primary_accountable_id, weak_pointer(), null: true)

      add(:accounting_quantity_id, references("measurement_measure", on_delete: :nilify_all))
      add(:onhand_quantity_id, references("measurement_measure", on_delete: :nilify_all))
      add(:unit_of_effort_id, references("measurement_unit", on_delete: :nilify_all))

      add(:stage_id, weak_pointer(ProcessSpecification), null: true)

      # optional context as in_scope_of
      add(:context_id, weak_pointer(), null: true)

      add(:creator_id, references("mn_user", on_delete: :nilify_all))

      add(:published_at, :timestamptz)
      add(:deleted_at, :timestamptz)
      add(:disabled_at, :timestamptz)

      timestamps(inserted_at: false, type: :utc_datetime_usec)
    end
  end

  def down do
    drop_pointable_table(ValueFlows.Observation.EconomicResource)
  end
end
