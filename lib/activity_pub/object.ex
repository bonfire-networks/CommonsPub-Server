# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule ActivityPub.Object do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias MoodleNet.Repo
  alias ActivityPub.Object

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "mn_ap_object" do
    field(:data, :map)
    field(:local, :boolean, default: true)
    field(:public, :boolean)

    timestamps()
  end

  def get_by_id(id), do: Repo.get(Object, id)

  def get_by_ap_id(ap_id) do
    Repo.one(from(object in Object, where: fragment("(?)->>'id' = ?", object.data, ^ap_id)))
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
    |> cast(attrs, [:data, :local, :public])
    |> validate_required(:data)
  end
end
