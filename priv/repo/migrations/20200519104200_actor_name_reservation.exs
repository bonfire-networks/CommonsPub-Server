defmodule MoodleNet.Repo.Migrations.ActorNameReservation do
  use Ecto.Migration

  def change do
    CommonsPub.Character.Migrations.name_reservation_change()
  end
end
