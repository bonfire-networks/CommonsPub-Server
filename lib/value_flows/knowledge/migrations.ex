defmodule ValueFlows.Knowledge.Migrations do
  use Ecto.Migration
  alias MoodleNet.Repo
  alias Ecto.ULID


  def change_action do
    create table(:vf_action) do

      add :label, :string
      add :input_output, :string
      add :pairs_with, :string
      add :resource_effect, :string

      add :community_id, references("mn_community", on_delete: :delete_all)
      add :creator_id, references("mn_user", on_delete: :nilify_all)

      add :published_at, :timestamptz
      add :deleted_at, :timestamptz
      add :disabled_at, :timestamptz

      timestamps(inserted_at: false, type: :utc_datetime_usec)

    end

  end

end
