defmodule CommonsPub.Repo.Migrations.AddMnPointerIdToApObject do
  use Ecto.Migration
  import Pointers.Migration

  def change do
    alter table("ap_object") do
      add(:mn_pointer_id, strong_pointer())
    end

    create(index("ap_object", [:mn_pointer_id]))
  end
end
