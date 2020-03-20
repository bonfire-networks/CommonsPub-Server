# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Resources.Resource do
  use MoodleNet.Common.Schema

  import MoodleNet.Common.Changeset,
    only: [change_public: 1, change_disabled: 1, validate_http_url: 2]

  alias Ecto.Changeset
  alias MoodleNet.Collections.Collection
  alias MoodleNet.Resources.Resource
  alias MoodleNet.Users.User

  table_schema "mn_resource" do
    belongs_to(:creator, User)
    belongs_to(:collection, Collection)
    # belongs_to(:primary_language, Language, type: :binary)
    field(:canonical_url, :string)
    field(:name, :string)
    field(:summary, :string)
    field(:url, :string)
    field(:license, :string)
    field(:author, :string)
    field(:icon, :string)
    field(:is_public, :boolean, virtual: true)
    field(:published_at, :utc_datetime_usec)
    field(:is_disabled, :boolean, virtual: true)
    field(:disabled_at, :utc_datetime_usec)
    field(:deleted_at, :utc_datetime_usec)
    timestamps()
  end

  @required ~w(name)a
  @cast @required ++ ~w(canonical_url is_public is_disabled license summary icon url author)a

  @spec create_changeset(User.t(), Collection.t(), map) :: Changeset.t()
  @doc "Creates a changeset for insertion of a resource with the given attributes."
  def create_changeset(creator, collection, attrs) do
    %Resource{}
    |> Changeset.cast(attrs, @cast)
    |> Changeset.validate_required(@required)
    |> Changeset.change(
      collection_id: collection.id,
      creator_id: creator.id,
      is_public: true
    )
    |> common_changeset()
  end

  @spec update_changeset(%Resource{}, map) :: Changeset.t()
  @doc "Creates a changeset for updating the resource with the given attributes."
  def update_changeset(%Resource{} = resource, attrs) do
    resource
    |> Changeset.cast(attrs, @cast)
    |> common_changeset()
  end

  defp common_changeset(changeset) do
    changeset
    |> change_disabled()
    |> change_public()
    |> validate_http_url(:url)
  end

end
