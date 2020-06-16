defmodule Circle.Migrations do

  use Ecto.Migration
  import Pointers.Migration

  def up() do

    # a circle is a group actor that is home to resources
    create_pointable_table(:circle, "01EAQ0ENYEFY2DZHATQWZ2AEEQ") do
      add :character_id, references("character", on_delete: :delete_all)
      add :context_id, references("mn_pointer", on_delete: :nilify_all) # points to the parent Thing of this Character
      add :extra_info, :map
    end

  end

  def down() do
    drop_pointable_table("circle", "01EAQ0ENYEFY2DZHATQWZ2AEEQ")
  end

end
