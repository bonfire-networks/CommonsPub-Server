defmodule CommonsPub.Repo.Migrations.AddContextToMN do
  use Ecto.Migration
  import Pointers.Migration

  def change do
    alter table(:mn_community) do
      add(:context_id, weak_pointer(), null: true)
    end

    create(index(:mn_community, :context_id))

    alter table(:mn_collection) do
      add(:context_id, weak_pointer(), null: true)
    end

    create(index(:mn_collection, :context_id))

    alter table(:mn_resource) do
      add(:context_id, weak_pointer(), null: true)
    end

    create(index(:mn_resource, :context_id))
  end
end
