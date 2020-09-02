defmodule CommonsPub.Repo.Migrations.ActorNameReservation do
  use Ecto.Migration

  def change do
    CommonsPub.Characters.Migrations.name_reservation_change()
  end
end
