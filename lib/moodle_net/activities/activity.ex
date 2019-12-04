# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Activities.Activity do
  use MoodleNet.Common.Schema

  import MoodleNet.Common.Changeset,
    only: [meta_pointer_constraint: 1, change_public: 1]

  alias MoodleNet.Users.User
  alias MoodleNet.Meta
  alias MoodleNet.Meta.Pointer
  alias Ecto.Changeset

  @type t :: %__MODULE__{}

  table_schema "mn_activity" do
    belongs_to(:user, User)
    belongs_to(:context, Pointer)
    field(:canonical_url, :string)
    field(:verb, :string)
    field(:is_local, :boolean)
    field(:is_public, :boolean, virtual: true)
    field(:published_at, :utc_datetime_usec)
    field(:deleted_at, :utc_datetime_usec)
    timestamps()
  end

  @required ~w(verb is_local)a
  @cast @required ++ ~w(canonical_url is_public)a

  def create_changeset(%Pointer{id: id} = pointer, %Pointer{} = context, %User{} = user, attrs) do
    Meta.assert_points_to!(pointer, __MODULE__)

    %__MODULE__{}
    |> Changeset.cast(attrs, @cast)
    |> Changeset.change(
      id: id,
      user_id: user.id,
      context_id: context.id,
      is_public: true
    )
    |> Changeset.validate_required(@required)
    |> common_changeset()
  end

  def update_changeset(%__MODULE__{} = activity, attrs) do
    activity
    |> Changeset.cast(attrs, @cast)
    |> common_changeset()
  end

  defp common_changeset(changeset) do
    changeset
    |> change_public()
    |> meta_pointer_constraint()
  end
end
