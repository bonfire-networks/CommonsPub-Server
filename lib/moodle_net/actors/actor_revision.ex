# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Actors.ActorRevision do
  use MoodleNet.Common.Schema
  alias Ecto.Changeset
  alias MoodleNet.Actors.{Actor, ActorRevision}

  standalone_schema "mn_actor_revision" do
    belongs_to :actor, Actor, type: :binary_id
    field :name, :string
    field :summary, :string
    field :icon, :string
    field :image, :string
    timestamps(updated_at: false)
  end

  @create_cast ~w(name summary icon image)a
  @create_required ~w()

  def create_changeset(%Actor{} = actor, attrs) do
    %ActorRevision{actor: actor}
    |> Changeset.cast(attrs, @create_cast)
    |> Changeset.validate_required(@create_required)
  end
end
