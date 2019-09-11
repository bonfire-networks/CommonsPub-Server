# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Users.User do
  @moduledoc """
  User model
  """
  use Ecto.Schema
  alias Ecto.Changeset
  alias MoodleNet.Users.{User, LocalUser}
  alias MoodleNet.Actors.Actor

  # @primary_key false
  @foreign_key_type :binary_id
  schema "mn_user" do
    field :email, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    field :confirmed_at, :utc_datetime
    timestamps()
  end

  @email_regexp ~r/.+\@.+\..+/

  @register_cast_attrs ~w(email password)a
  @register_required_attrs ~w(email password_hash)a

  @doc "Create a changeset for registration"
  def register_changeset(%User{}=user, attrs) do
    user
    |> Changeset.cast(attrs, @register_cast_attrs)
    |> Changeset.validate_format(:email, @email_regexp)
    |> Changeset.unique_constraint(:email)
    |> Changeset.foreign_key_constraint(:user_id)
    |> Changeset.validate_length(:password, min: 6)
    |> lower_case_email()
    |> hash_password()
    |> Changeset.validate_required(@register_required_attrs)
  end

  @doc "Create a changeset for confirming an email"
  def confirm_email_changeset(%__MODULE__{} = user) do
    Changeset.change user,
      confirmed_at: DateTime.truncate(DateTime.utc_now(), :second)
  end

  # internals

  defp lower_case_email(%Changeset{valid?: false} = ch), do: ch

  defp lower_case_email(%Changeset{} = ch) do
    {_, email} = Changeset.fetch_field(ch, :email)
    Changeset.change(ch, email: String.downcase(email))
  end

  defp hash_password(%Changeset{valid?: true, changes: %{password: pass}} = ch),
    do: Changeset.change(ch, password_hash: Comeonin.Pbkdf2.hashpwsalt(pass))
  
  defp hash_password(changeset), do: changeset

end
