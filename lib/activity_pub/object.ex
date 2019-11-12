# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule ActivityPub.Object do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias MoodleNet.Repo
  alias ActivityPub.Fetcher
  alias ActivityPub.Object

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "ap_object" do
    field(:data, :map)
    field(:local, :boolean, default: true)
    field(:public, :boolean)
    belongs_to(:mn_pointer, MoodleNet.Meta.Pointer)

    timestamps()
  end

  def get_by_id(id), do: Repo.get(Object, id)

  def get_by_ap_id(ap_id) do
    Repo.one(from(object in Object, where: fragment("(?)->>'id' = ?", object.data, ^ap_id)))
  end

  def get_by_pointer_id(pointer_id), do: Repo.get_by(Object, mn_pointer_id: pointer_id)

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

  def update(object, attrs) do
    object
    |> change(attrs)
    |> Repo.update()
  end

  def normalize(_, fetch_remote \\ true)
  def normalize(%Object{} = object, _), do: object
  def normalize(%{"id" => ap_id}, fetch_remote), do: normalize(ap_id, fetch_remote)
  def normalize(ap_id, false) when is_binary(ap_id), do: get_by_ap_id(ap_id)

  def normalize(ap_id, true) when is_binary(ap_id) do
    with {:ok, object} <- Fetcher.fetch_object_from_id(ap_id) do
      object
    else
      _e -> nil
    end
  end

  def normalize(_, _), do: nil

  def make_tombstone(%Object{data: %{"id" => id, "type" => type}}, deleted \\ DateTime.utc_now()) do
    %{
      "id" => id,
      "formerType" => type,
      "deleted" => deleted,
      "type" => "Tombstone"
    }
  end

  def swap_object_with_tombstone(object) do
    tombstone = make_tombstone(object)

    object
    |> Object.changeset(%{data: tombstone})
    |> Repo.update()
  end

  def delete(%Object{} = object) do
    with {:ok, _obj} = swap_object_with_tombstone(object) do
      {:ok, object}
    end
  end
end
