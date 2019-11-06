# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Users.User do
  @moduledoc """
  User model
  """
  use MoodleNet.Common.Schema
  import MoodleNet.Common.Changeset, only: [meta_pointer_constraint: 1]
  alias Ecto.Changeset
  alias MoodleNet.Users.{User, EmailConfirmToken}
  alias MoodleNet.Actors.Actor
  alias MoodleNet.Meta
  alias MoodleNet.Meta.Pointer

  meta_schema "mn_user" do
    field(:email, :string)
    field(:password, :string, virtual: true)
    field(:password_hash, :string)
    field(:confirmed_at, :utc_datetime_usec)
    field(:deleted_at, :utc_datetime_usec)
    field(:wants_email_digest, :boolean)
    field(:wants_notifications, :boolean)
    field(:actor, :any, virtual: true) # todo: can we somehow squeeze this into ecto's relations?
    has_many :email_confirm_tokens, EmailConfirmToken
    timestamps()
  end

  @email_regexp ~r/.+\@.+\..+/

  @register_cast_attrs ~w(email password wants_email_digest wants_notifications)a
  @register_required_attrs ~w(email password wants_email_digest wants_notifications)a

  @doc "Create a changeset for registration"
  def register_changeset(%Pointer{id: id} = pointer, attrs) do
    Meta.assert_points_to!(pointer, __MODULE__)
    %User{id: id}
    |> Changeset.cast(attrs, @register_cast_attrs)
    |> Changeset.validate_required(@register_required_attrs)
    |> common_changeset()
  end

  @doc "Create a changeset for confirming an email"
  def confirm_email_changeset(%__MODULE__{} = user) do
    Changeset.change(user, confirmed_at: DateTime.utc_now())
  end

  @doc "Create a changeset for unconfirming an email"
  def unconfirm_email_changeset(%__MODULE__{} = user) do
    Changeset.change(user, confirmed_at: nil)
  end

  @update_cast_attrs ~w(email password wants_email_digest wants_notifications)a

  @doc "Update the attributes for a user"
  def update_changeset(%User{} = user, attrs) do
    user
    |> Changeset.cast(attrs, @update_cast_attrs)
    |> common_changeset()
  end

  def soft_delete_changeset(%User{} = user),
    do: MoodleNet.Common.Changeset.soft_delete_changeset(user)

  defp common_changeset(changeset) do
    changeset
    |> Changeset.validate_format(:email, @email_regexp)
    |> Changeset.unique_constraint(:email)
    |> Changeset.validate_length(:password, min: 6)
    |> meta_pointer_constraint()
    |> hash_password()
    |> lower_case_email()
  end

  # internals

  defp lower_case_email(%Changeset{valid?: false} = ch), do: ch

  defp lower_case_email(%Changeset{} = ch) do
    {_, email} = Changeset.fetch_field(ch, :email)
    Changeset.change(ch, email: String.downcase(email))
  end

  defp hash_password(%Changeset{valid?: true, changes: %{password: pass}} = ch),
    do: Changeset.change(ch, password_hash: Argon2.hash_pwd_salt(pass))

  defp hash_password(changeset), do: changeset

end
