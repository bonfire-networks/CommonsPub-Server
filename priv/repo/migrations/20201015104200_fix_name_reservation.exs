defmodule CommonsPub.Repo.Migrations.ActorNameReservationFix do
  use Ecto.Migration

  def change do
    CommonsPub.Characters.Migrations.name_reservation_fix()
  end
end
