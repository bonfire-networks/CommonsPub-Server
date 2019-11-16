# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Users.User do
  @moduledoc """
  User model
  """
  use MoodleNet.Common.Schema

  import MoodleNet.Common.Changeset,
    only: [meta_pointer_constraint: 1, change_synced_timestamp: 3, change_public: 1]

  alias Ecto.Changeset
  alias MoodleNet.Users.{LocalUser, User, EmailConfirmToken}
  alias MoodleNet.Actors.Actor
  alias MoodleNet.Meta
  alias MoodleNet.Meta.Pointer

  meta_schema "mn_user" do
    belongs_to(:actor, Actor)
    belongs_to(:local_user, LocalUser)
    belongs_to(:primary_language, Language)
    field(:name, :string)
    field(:summary, :string)
    field(:location, :string)
    field(:website, :string)
    field(:icon, :string)
    field(:image, :string)
    field(:is_public, :boolean, virtual: true)
    field(:published_at, :utc_datetime_usec)
    field(:is_disabled, :boolean, virtual: true)
    field(:disabled_at, :utc_datetime_usec)
    field(:is_deleted, :boolean, virtual: true)
    field(:deleted_at, :utc_datetime_usec)
    has_many(:email_confirm_tokens, EmailConfirmToken)
    timestamps(inserted_at: :created_at)
  end

  @email_regexp ~r/.+\@.+\..+/

  @register_cast_attrs ~w(name summary location website icon image is_public is_disabled)a
  @register_required_attrs @register_cast_attrs

  @doc "Create a changeset for registration"
  def register_changeset(%Pointer{id: id} = pointer, %Actor{} = actor, attrs) do
    Meta.assert_points_to!(pointer, __MODULE__)

    %User{id: id}
    |> Changeset.cast(attrs, @register_cast_attrs)
    |> Changeset.validate_required(@register_required_attrs)
    |> Changeset.change(actor_id: actor.id)
    |> common_changeset()
  end

  def local_register_changeset(
        %Pointer{id: id} = pointer,
        actor,
        %LocalUser{} = local_user,
        attrs
      ) do
    register_changeset(pointer, actor, attrs)
    |> Changeset.put_assoc(:local_user, local_user)
  end

  @update_cast_attrs ~w(name summary location website icon image is_public is_disabled)a

  @doc "Update the attributes for a user"
  def update_changeset(%User{} = user, attrs) do
    user
    |> Changeset.cast(attrs, @update_cast_attrs)
    |> common_changeset()
  end

  def soft_delete_changeset(%User{} = user),
    do: MoodleNet.Common.Changeset.soft_delete_changeset(user)

  def vivify_virtuals(%User{}=user) do
    %{ user |
       is_public: not is_nil(user.published_at),
       is_disabled: not is_nil(user.disabled_at),
       is_deleted: not is_nil(user.deleted_at),
    }
  end	 
       

  defp common_changeset(changeset) do
    changeset
    |> change_synced_timestamp(:is_disabled, :disabled_at)
    |> change_public()
    |> meta_pointer_constraint()
  end
end
