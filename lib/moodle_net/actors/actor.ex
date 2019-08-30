# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Actors.Actor do
  use Ecto.Schema
  alias Ecto.Changeset
  alias MoodleNet.Actors.Actor

  schema "mn_actors" do
    field :is_local, :boolean
    timestamps()
  end

  @cast_attrs ~w(is_local)a
  @required_attrs @cast_attrs

  def changeset(%Actor{}=actor, attrs) do
    actor
    |> Changeset.cast(attrs, @cast_attrs)
    |> Changeset.validate_required(@required_attrs)
  end

end
