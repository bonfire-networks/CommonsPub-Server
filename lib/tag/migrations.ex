defmodule Tag.Migrations do

  use Ecto.Migration
  import Pointers.Migration

  def up() do

    create_pointable_table(:taggable, "TAGSCANBECATEG0RY0RHASHTAG") do

      add :prefix, :string # eg. @ or + or #

      add :context_id, references(Pointers.Config.pointer_table(), on_delete: :nilify_all) # eg. community who curates this tag
      add :parent_tag_id, references(:taggable, on_delete: :nilify_all) # eg. Mamals is a parent of Cat
      add :same_as_tag_id, references(:taggable, on_delete: :nilify_all) # eg. Olive Oil is the same as Huile d'olive

      add :taxonomy_tag_id, references(:taxonomy_tag, on_delete: :nilify_all, type: :integer) # 

    end

  end

  def down() do
    drop_pointable_table(:taggable, "TAGSCANBECATEG0RY0RHASHTAG")
  end

end
