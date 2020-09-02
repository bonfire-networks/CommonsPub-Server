defmodule ValueFlows.Knowledge.Migrations do
  use Ecto.Migration
  alias CommonsPub.Repo
  alias Ecto.ULID

  def change_action do
    create table(:vf_action) do
      add(:label, :string)
      add(:input_output, :string)
      add(:pairs_with, :string)
      add(:resource_effect, :string)
      add(:note, :text)

      timestamps(inserted_at: false, type: :utc_datetime_usec)
    end
  end
end
