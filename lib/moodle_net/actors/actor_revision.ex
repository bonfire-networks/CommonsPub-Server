# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Actors.ActorRevision do
  use Ecto.Schema
  alias Ecto.Changeset
  alias MoodleNet.Actors.{Actor, ActorRevision}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key :binary_id
  schema "mn_actor_revision" do
    belongs_to :actor, Actor, type: :binary_id
    field :name, :string
    field :summary, :string
    field :icon, :string
    field :image, :string
    field :extra, {:map, :string}
    timestamps(updated_at: false)
  end

  @create_cast ~w(name summary icon image extra)a
  @create_required ~w()

  def create_changeset(%Actor{} = actor, attrs) do
    %ActorRevision{actor: actor}
    |> Changeset.cast(attrs, @create_cast)
    |> Changeset.validate_required(@create_required)
  end

  @update_cast ~w(icon image extra)

  def update_changeset(%ActorRevision{}=actor_revision, attrs) do
    Changeset.cast(actor_revision, attrs, @update_cast)
  end

  def update_extra(%ActorRevision{}=actor, extra) when is_map(extra) do
    Changeset.change(actor, extra: extra)
  end
end
