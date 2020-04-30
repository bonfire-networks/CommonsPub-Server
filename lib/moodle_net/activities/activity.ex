# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Activities.Activity do
  use MoodleNet.Common.Schema

  import MoodleNet.Common.Changeset, only: [change_public: 1]
  alias MoodleNet.Activities
  alias MoodleNet.Activities.Activity
  alias MoodleNet.Feeds.FeedActivity
  alias MoodleNet.Users.User
  alias MoodleNet.Meta.Pointer
  alias Ecto.Changeset

  @type t :: %Activity{}

  table_schema "mn_activity" do
    belongs_to(:creator, User)
    belongs_to(:context, Pointer)
    has_many :feed_activities, FeedActivity
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

  def create_changeset(%User{id: creator_id}, %{id: context_id}, %{}=attrs)
  when is_binary(creator_id) and is_binary(context_id) do
    %Activity{}
    |> Changeset.cast(attrs, @cast)
    |> Changeset.change(
      creator_id: creator_id,
      context_id: context_id,
      is_public: true
    )
    |> Changeset.validate_required(@required)
    |> common_changeset()
  end

  def update_changeset(%Activity{} = activity, attrs) do
    activity
    |> Changeset.cast(attrs, @cast)
    |> common_changeset()
  end

  defp common_changeset(changeset) do
    changeset
    |> change_public()
  end

end
