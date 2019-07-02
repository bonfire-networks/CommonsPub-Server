# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule ActivityPub.Object do
  use Ecto.Schema
  import Ecto.Changeset

  alias MoodleNet.Repo

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "objects" do
    field(:data, :map)
    field(:local, :boolean, default: true)
    field(:actor, :string)
    field(:recipients, {:array, :string}, default: [])

    timestamps()
  end

  def insert(attrs) do
    attrs
    |> changeset()
    |> Repo.insert()
  end

  def changeset(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
  end

  def changeset(object, attrs) do
    object
    |> cast(attrs, [:data, :local, :actor, :recipients])
    |> validate_required(:data)
  end
end
