# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNet.Users.User do
  @moduledoc """
  User model
  """
  use Ecto.Schema
  alias Ecto.Changeset
  alias MoodleNet.Users.{User, LocalUser, RemoteUser}
  alias MoodleNet.Actors.Actor

  schema "mn_users" do
    belongs_to :actor, Actor
    belongs_to :local_user, LocalUser
    belongs_to :remote_user, RemoteUser
    
    timestamps()
  end

  def changeset(%User{}=user, attrs) do
    user
    |> Changeset.cast(attrs, [:email])
    |> Changeset.validate_format(:email, ~r/.+\@.+\..+/)
    # |> Changeset.put_assoc(:primary_actor, actor)
    |> Changeset.change(actor: actor, actor_id: actor_id)
    |> Changeset.validate_required([:actor_id, :email])
    |> Changeset.unique_constraint(:email)
    |> lower_case_email()
    |> whitelist_email()
  end

  defp lower_case_email(%Changeset{valid?: false} = ch), do: ch

  defp lower_case_email(%Changeset{} = ch) do
    {_, email} = Changeset.fetch_field(ch, :email)
    Changeset.change(ch, email: String.downcase(email))
  end

  defp whitelist_email(%Changeset{valid?: false} = ch), do: ch

  defp whitelist_email(%Changeset{} = ch) do
    {_, email} = Changeset.fetch_field(ch, :email)

    if MoodleNet.Accounts.is_email_in_whitelist?(email) do
      ch
    else
      Changeset.add_error(ch, :email, "You cannot register with this email address",
        validation: "inclusion"
      )
    end
  end

  def confirm_email_changeset(%__MODULE__{} = user) do
    Changeset.change(user, confirmed_at: DateTime.utc_now() |> DateTime.truncate(:second))
  end

end
