defmodule MoodleNet.Repo.Migrations.AddMnPointerIdToApObject do
  use Ecto.Migration

  def change do
    alter table("ap_object") do
      add :mn_pointer_id, references("mn_pointer")
    end

    create index("ap_object", [:mn_pointer_id])
  end
end
