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
  import MoodleNet.Common.Changeset, only: [validate_email: 2]
  alias Ecto.Changeset

  @type t :: %__MODULE__{}

  table_schema "mn_access_register_email" do
    field(:email, :string, primary_key: true)
    timestamps()
  end

  @create_cast ~w(email)a
  @create_required @create_cast


  def create_changeset(fields) do
    %__MODULE__{}
    |> Changeset.cast(fields, @create_cast)
    |> Changeset.validate_required(@create_required)
    |> validate_email(:email)
    |> Changeset.unique_constraint(:email, name: "mn_access_register_email")
  end
end
