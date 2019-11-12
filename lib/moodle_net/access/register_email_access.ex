# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Access.RegisterEmailAccess do
  @moduledoc """
  A simple standalone schema listing email addresses which are
  permitted to register a MoodleNet account while public signup is
  disabled.
  """

  use MoodleNet.Common.Schema
  alias Ecto.Changeset
  import MoodleNet.Common.Changeset, only: [validate_email: 2]

  standalone_schema "mn_access_register_email" do
    field(:email, :string, primary_key: true)
    timestamps()
  end

  @cast ~w(email)a
  @required @cast

  @doc "A changeset for both creation and update purposes"
  def changeset(entry \\ %__MODULE__{}, fields)
  def changeset(%__MODULE__{}=entry, fields) do
    entry
    |> Changeset.cast(fields, @cast)
    |> Changeset.validate_required(@required)
    |> validate_email(:email)
    |> Changeset.unique_constraint(:email)
  end
end
