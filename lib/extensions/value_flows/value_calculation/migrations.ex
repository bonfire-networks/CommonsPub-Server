# SPDX-License-Identifier: AGPL-3.0-only
defmodule ValueFlows.ValueCalculation.Migrations do
  use Ecto.Migration

  import Pointers.Migration

  def up do
    create_pointable_table(ValueFlows.ValueCalculation) do
      # TODO: consider max size
      add(:formula, :string, length: 5000, null: false)

      add(:creator_id, references("mn_user", on_delete: :nilify_all))
      add(:context_id, weak_pointer(), null: true)
      add(:value_unit_id, weak_pointer(Measurement.Unit), null: true)
    end
  end

  def down do
    drop_pointable_table(ValueFlows.ValueCalculation)
  end
end
