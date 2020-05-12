defmodule MoodleNet.Repo.Migrations.AddMnPointerIndex do
  use Ecto.Migration

  def change do
    drop index(:ap_object, :mn_pointer_id)
    create unique_index(:ap_object, :mn_pointer_id)
  end
end
