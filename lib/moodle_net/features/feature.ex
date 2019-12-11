# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Features.Feature do
  use MoodleNet.Common.Schema

  import MoodleNet.Common.Changeset

  alias Ecto.Changeset
  alias MoodleNet.Meta.Pointer
  alias MoodleNet.Users.User

  @type t :: %__MODULE__{}

  table_schema "mn_feature" do
    belongs_to(:creator, User)
    belongs_to(:context, Pointer)
    field(:canonical_url, :string)
    field(:is_local, :boolean)
    field(:deleted_at, :utc_datetime_usec)
    timestamps()
  end

  @create_cast ~w(canonical_url is_local)a

  def create_changeset(%User{id: creator_id}, %{id: context_id} = context, fields) do
    %__MODULE__{}
    |> Changeset.cast(fields, @create_cast)
    |> Changeset.validate_required(@create_cast)
    |> Changeset.change(creator_id: creator_id, context_id: context_id)
  end

end
