defmodule Tag.Migrations do
  use Ecto.Migration
  import Pointers.Migration

  def up() do
    pointer = Application.get_env(:pointers, :schema_pointers, "mn_pointer")

    create_pointable_table(:tags, "TAGSCANBECATEG0RY0RHASHTAG") do
      # eg. @ or + or #
      add(:prefix, :string)

      # eg. community who curates this tag
      add(
        :context_id,
        references(pointer, on_update: :update_all, on_delete: :nilify_all)
      )

      # eg. Mamals is a parent of Cat
      add(:parent_tag_id, references(:tags, on_update: :update_all, on_delete: :nilify_all))
      # eg. Olive Oil is the same as Huile d'olive
      add(:same_as_tag_id, references(:tags, on_update: :update_all, on_delete: :nilify_all))

      #
      add(
        :taxonomy_tag_id,
        references("taxonomy_tag", on_update: :update_all, on_delete: :nilify_all, type: :integer)
      )
    end

    create_if_not_exists table(:tags_things, primary_key: false) do
      add(
        :pointer_id,
        references(pointer, on_update: :update_all, on_delete: :delete_all)
      )

      add(:tag_id, references(:tags, on_update: :update_all, on_delete: :delete_all))
    end

    create(unique_index(:tags_things, [:pointer_id, :tag_id]))
  end

  def down() do
    drop_pointable_table(:tags, "TAGSCANBECATEG0RY0RHASHTAG")
  end
end
