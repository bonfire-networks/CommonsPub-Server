# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Comments.Comment do
  use MoodleNet.Common.Schema

  import MoodleNet.Common.Changeset,
    only: [change_public: 1, change_synced_timestamp: 3]

  alias Ecto.Changeset
  alias MoodleNet.Actors.Actor
  alias MoodleNet.Comments.{Comment, Thread}
  alias MoodleNet.Meta
  alias MoodleNet.Meta.Pointer
  alias MoodleNet.Users.User

  table_schema "mn_comment" do
    belongs_to(:creator, User)
    belongs_to(:thread, Thread)
    belongs_to(:reply_to, Comment)
    field(:canonical_url, :string)
    field(:content, :string)
    field(:is_local, :boolean)
    field(:is_hidden, :boolean, virtual: true)
    field(:hidden_at, :utc_datetime_usec)
    field(:is_public, :boolean, virtual: true)
    field(:published_at, :utc_datetime_usec)
    field(:deleted_at, :utc_datetime_usec)
    timestamps()
  end

  @required ~w(content is_local)a
  @cast @required ++ ~w(canonical_url is_hidden is_public)a

  @spec create_changeset(User.t(), Thread.t(), map) :: Changeset.t()
  def create_changeset(creator, thread, attrs) do
    %Comment{}
    |> Changeset.cast(attrs, @cast)
    |> Changeset.change(
      creator_id: creator.id,
      thread_id: thread.id,
      is_public: true
    )
    |> Changeset.validate_required(@required)
    |> common_changeset()
  end

  def reply_to_changeset(%Changeset{} = changeset, %Comment{} = reply_to) do
    Changeset.put_change(changeset, :reply_to_id, reply_to.id)
  end

  @spec update_changeset(Comment.t(), map) :: Changeset.t()
  def update_changeset(%Comment{} = comment, attrs) do
    comment
    |> Changeset.cast(attrs, @cast)
    |> common_changeset()
  end

  defp common_changeset(changeset) do
    changeset
    |> change_public()
    |> change_synced_timestamp(:is_hidden, :hidden_at)
  end
end
