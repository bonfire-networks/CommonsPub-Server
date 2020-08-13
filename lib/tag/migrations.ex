defmodule Tag.Migrations do
  use Ecto.Migration
  import Pointers.Migration

  defp category_table(), do: CommonsPub.Tag.Category.__schema__(:source)
  defp taggable_table(), do: CommonsPub.Tag.Taggable.__schema__(:source)

  def up() do
    # pointer = Application.get_env(:pointers, :schema_pointers, "mn_pointer")

    # cleanup old stuff first
    drop_pointable_table(:tags, "TAGSCANBECATEG0RY0RHASHTAG")
    flush()

    create_mixin_table(taggable_table()) do
      add(:prefix, :string)
      add(:facet, :string)
    end

    create_pointable_table(category_table(), "TAGSCANBECATEG0RY0RHASHTAG") do
      add(:creator_id, references("mn_user", on_delete: :nilify_all))

      add(:caretaker_id, weak_pointer(), null: true)

      # eg. Mamals is a parent of Cat
      add(
        :parent_category_id,
        references(category_table(), on_update: :update_all, on_delete: :nilify_all)
      )

      # eg. Olive Oil is the same as Huile d'olive
      add(
        :same_as_category_id,
        references(category_table(), on_update: :update_all, on_delete: :nilify_all)
      )

      add(:published_at, :timestamptz)
      add(:deleted_at, :timestamptz)
      add(:disabled_at, :timestamptz)
    end

    create_if_not_exists table(:tags_things, primary_key: false) do
      add(:pointer_id, strong_pointer(), null: false)

      add(:tag_id, references(taggable_table(), on_update: :update_all, on_delete: :delete_all))
    end

    create(unique_index(:tags_things, [:pointer_id, :tag_id]))
  end

  def down() do
    drop_pointable_table(category_table(), "TAGSCANBECATEG0RY0RHASHTAG")
    drop_mixin_table(taggable_table())
  end
end
