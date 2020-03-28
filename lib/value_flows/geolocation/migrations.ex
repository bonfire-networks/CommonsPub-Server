defmodule ValueFlows.Geolocation.Migrations do

  use Ecto.Migration

  def change do
    create table(:vf_spatial_things) do

      add :name, :string
      add :note, :text
      add :mappable_address, :string
      add :point, :point
      # add :lat, :float
      # add :long, :float
      add :alt, :float

      add :actor_id, references("mn_actor", on_delete: :delete_all)
      add :community_id, references("mn_community", on_delete: :delete_all)
      add :creator_id, references("mn_user", on_delete: :nilify_all)
      add :inbox_id, references("mn_feed", on_delete: :nilify_all)
      add :outbox_id, references("mn_feed", on_delete: :nilify_all)
      add :published_at, :timestamptz
      add :deleted_at, :timestamptz
      add :disabled_at, :timestamptz

      timestamps(inserted_at: false, type: :utc_datetime_usec)

    end

  end
end
