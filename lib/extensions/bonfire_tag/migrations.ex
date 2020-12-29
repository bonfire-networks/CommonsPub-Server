defmodule Bonfire.Tag.Migrations do
  import Ecto.Migration
  import Pointers.Migration

  alias Bonfire.Tag.Taggable

  def category_table(), do: Bonfire.Classify.Category.__schema__(:source)
  def category_id(), do: Bonfire.Classify.Category.__schema__(:table_id)

  def taggable_table(), do: Taggable.__schema__(:source)

  def up() do
    # cleanup old stuff first
    drop_pointable_table(Bonfire.Classify.Category)
    flush()

    create_mixin_table(Taggable) do
      add(:prefix, :string)
      add(:facet, :string)
    end

    create_pointable_table(Bonfire.Classify.Category) do
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

    flush()

    create_if_not_exists table(:tags_things, primary_key: false) do
      add(:pointer_id, strong_pointer(), null: false)

      add(:tag_id, strong_pointer(Bonfire.Tag.Taggable), null: false)
    end

    create(unique_index(:tags_things, [:pointer_id, :tag_id]))
  end

  def down() do
    drop_pointable_table(Bonfire.Classify.Category)
    drop_mixin_table(Bonfire.Tag.Taggable)
  end
end
