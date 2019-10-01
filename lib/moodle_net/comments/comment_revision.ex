# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Comments.CommentRevision do
  use MoodleNet.Common.Schema
  alias Ecto.Changeset
  alias MoodleNet.Comments.{Comment, CommentRevision}

  standalone_schema "mn_comment_revision" do
    belongs_to(:comment, Comment)
    field(:content, :string)
    timestamps(updated_at: false)
  end

  @create_cast ~w(content)a
  @create_required @create_cast

  def create_changeset(%Comment{} = comment, attrs) do
    %CommentRevision{}
    |> Changeset.cast(attrs, @create_cast)
    |> Changeset.validate_required(@create_cast)
    |> Changeset.put_assoc(:comment, comment)
  end
end
