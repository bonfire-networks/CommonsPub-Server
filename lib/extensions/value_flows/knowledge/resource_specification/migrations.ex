defmodule ValueFlows.Knowledge.ResourceSpecification.Migrations do
  use Ecto.Migration
  # alias MoodleNet.Repo
  # alias Ecto.ULID
  import Pointers.Migration

  alias ValueFlows.Knowledge.ResourceSpecification
  alias ValueFlows.Observation.EconomicResource
  alias ValueFlows.Observation.EconomicEvent

  # defp resource_table(), do: EconomicResource.__schema__(:source)

  def up do
    create_pointable_table(ValueFlows.Knowledge.ResourceSpecification) do
      add(:name, :string)
      add(:note, :text)

      add(:image_id, references(:mn_content))

      # add(:resource_classified_as, {:array, :string}, virtual: true)

      add(:default_unit_of_effort_id, references("measurement_unit", on_delete: :nilify_all))

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
    drop_pointable_table(ValueFlows.Knowledge.ResourceSpecification)
  end
end
