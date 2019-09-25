# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Common.Changeset do
  @moduledoc "Helper functions for changesets"

  alias Ecto.Changeset
  alias MoodleNet.Mail.Checker

  @spec validate_email(Changeset.t, atom) :: Changeset.t
  @doc "Validates an email for correctness"
  def validate_email(changeset, field) do
    with {:ok, email} <- Changeset.fetch_change(changeset, field),
         {:error, reason} <- Checker.validate_email(email) do
      message = validate_email_message(reason)
      Changeset.add_error(changeset, field, message)
    else _ -> changeset
    end
  end

  @spec validate_email_domain(Changeset.t, atom) :: Changeset.t
  def validate_email_domain(changeset, field) do
    with {:ok, domain} <- Changeset.fetch_change(changeset, field),
         {:error, reason} <- Checker.validate_domain(domain) do
      message = validate_email_message(reason)
      Changeset.add_error(changeset, field, message)
    else _ -> changeset
    end
  end

  defp validate_email_message(:format), do: "is of the wrong format"
  defp validate_email_message(:mx), do: "failed an MX record check"

  @spec meta_pointer_constraint(Changeset.t()) :: Changeset.t()
  @doc "Adds a foreign key constraint for pointer on the id"
  def meta_pointer_constraint(changeset),
    do: Changeset.foreign_key_constraint(changeset, :id)

  @doc "Creates a changest for deleting an entity"
  def soft_delete_changeset(it, column \\ :deleted_at),
    do: Changeset.change(it, {column, DateTime.utc_now()})

  @doc "Keeps published_at in accord with is_public"
  def change_public(%Changeset{}=changeset),
    do: change_synced_timestamp(changeset, :is_public, :published_at)

  @doc """
  If a changeset includes a change to `bool`, we ensure that the
  `timestamp` field is updated if required. In the case of true, this
  means setting it to now if it is null and in the case of false, this
  means setting it to null if it is not null.
  """
  def change_synced_timestamp(changeset, bool_field, timestamp_field) do
    bool_val = Changeset.fetch_change(changeset, bool_field)
    timestamp_val = Changeset.fetch_field(changeset, timestamp_field)
    case {bool_val, timestamp_val} do
      {{:ok, true}, {:data, value}} when not is_nil(value) -> changeset

      {{:ok, true}, _} ->
	Changeset.change(changeset, [{timestamp_field, DateTime.utc_now()}])

      {{:ok, false}, {:data, value}} when not is_nil(value) ->
	Changeset.change(changeset, [{timestamp_field, nil}])

	_ -> changeset
    end
  end

end
