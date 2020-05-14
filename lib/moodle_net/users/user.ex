# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Users.User do
  @moduledoc """
  User model
  """
  use MoodleNet.Common.Schema

  import MoodleNet.Common.Changeset,
    only: [change_synced_timestamp: 3, change_public: 1]

  alias Ecto.Changeset
  alias MoodleNet.Actors.Actor
  alias MoodleNet.Feeds.Feed
  alias MoodleNet.Uploads.Content
  alias MoodleNet.Users
  alias MoodleNet.Users.{LocalUser, User}

  table_schema "mn_user" do
    belongs_to(:actor, Actor)
    belongs_to(:local_user, LocalUser)
    belongs_to(:inbox_feed, Feed, foreign_key: :inbox_id)
    belongs_to(:outbox_feed, Feed, foreign_key: :outbox_id)
    # belongs_to(:primary_language, Language)
    field(:canonical_url, :string, virtual: true)
    field(:preferred_username, :string, virtual: true)
    field(:name, :string)
    field(:summary, :string)
    field(:location, :string)
    field(:website, :string)
    belongs_to(:icon, Content)
    belongs_to(:image, Content)
    field(:is_public, :boolean, virtual: true)
    field(:published_at, :utc_datetime_usec)
    field(:is_disabled, :boolean, virtual: true)
    field(:disabled_at, :utc_datetime_usec)
    field(:deleted_at, :utc_datetime_usec)
    field(:stale_error, :string, virtual: true)
    field(:extra_info, :map)
    timestamps()
  end

  @register_required ~w(name)a
  @register_cast @register_required ++
    ~w(name summary location website extra_info icon_id image_id is_public is_disabled inbox_id outbox_id)a

  @doc "Create a changeset for registration"
  def register_changeset(%Actor{id: id}, %{} = attrs) do
    %User{}
    |> Changeset.cast(attrs, @register_cast)
    |> Changeset.validate_required(@register_required)
    |> Changeset.change(actor_id: id)
    |> common_changeset()
  end

  def local_register_changeset(%Actor{} = actor, %LocalUser{id: id}, %{} = attrs) do
    register_changeset(actor, attrs)
    |> Changeset.put_change(:local_user_id, id)
  end

  @update_cast [] ++
    ~w(name summary location website extra_info icon_id image_id is_public is_disabled inbox_id outbox_id)a

  @doc "Update the attributes for a user"
  def update_changeset(%User{} = user, attrs) do
    user
    |> Changeset.cast(attrs, @update_cast)
    |> common_changeset()
  end

  def soft_delete_changeset(%User{} = user),
    do: MoodleNet.Common.Changeset.soft_delete_changeset(user)

  defp common_changeset(changeset) do
    changeset
    |> change_synced_timestamp(:is_disabled, :disabled_at)
    |> change_public()
  end

  ### behaviour callbacks

  def context_module, do: Users

  def queries_module, do: Users.Queries

  def follow_filters, do: [join: :actor, preload: :actor]

end
