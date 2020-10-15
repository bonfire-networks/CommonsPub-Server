defmodule CommonsPub.Characters.NameReservation do
  use Ecto.Schema
  alias Ecto.Changeset

  alias __MODULE__

  @primary_key {:id, Cloak.Ecto.SHA256, autogenerate: false}
  schema "actor_name_reservation" do
    timestamps(type: :utc_datetime_usec, inserted_at: :created_at, updated_at: false)
  end

  def changeset(name) when is_binary(name) do
    Changeset.change(%NameReservation{}, id: name)
    |> Changeset.unique_constraint(:name,
      name: "actor_name_reservation_pkey"
    )
  end
end
