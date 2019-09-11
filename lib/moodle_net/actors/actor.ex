# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Actors.Actor do
  use Ecto.Schema
  alias Ecto.Changeset
  alias MoodleNet.Actors.Actor
  alias MoodleNet.Instances.Instance

  @primary_key {:id,:binary_id, autogenerate: false}
  @foreign_key :binary_id
  schema "mn_actor" do
    belongs_to :instance, Instance
    field :preferred_username, :string
    field :icon, :string
    field :image, :string
    field :extra, {:map, :string}
    timestamps()
  end

  @create_cast ~w(is_local preferred_username icon image)a
  @create_required ~w(is_local)

  def create_changeset(id, attrs) do
    %Actor{id: id}
    |> Changeset.cast(attrs, @create_cast)
    |> Changeset.validate_required(@create_required)
    
    |> Changeset.foreign_key_constraint(:id)
    |> Changeset.unique_constraint(:preferred_username, name: :mn_actor_preferred_username_instance_key)
    |> validate_username()
  end

  @update_cast ~w(preferred_username icon image extra)

  def update_changeset(%Actor{}=actor, attrs) do
    actor
    |> Changeset.cast(attrs, @update_cast)
    |> validate_username()
  end

  defp validate_username(changeset) do
    
    case Changeset.fetch_change(changeset, :preferred_username) do
      :error -> changeset
      {:ok, name} ->
    end
  end
    

end
