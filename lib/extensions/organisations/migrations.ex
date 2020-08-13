defmodule Organisation.Migrations do
  use Ecto.Migration
  import Pointers.Migration

  def up() do
    # a organisation is a group actor that is home to resources
    create_pointable_table(:organisation, "0RGAN1SAT10N0FPE0P1EP01NTY") do
      add(:character_id, references("character", on_delete: :delete_all))
      # points to the parent Thing of this Character
      add(:context_id, references("mn_pointer", on_delete: :nilify_all))
      add(:extra_info, :map)
    end
  end

  def down() do
    drop_pointable_table("organisation", "0RGAN1SAT10N0FPE0P1EP01NTY")
  end

  def down_circle() do
    drop_pointable_table("circle", "01EAQ0ENYEFY2DZHATQWZ2AEEQ")
  end
end
