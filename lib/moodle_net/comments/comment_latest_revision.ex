# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Comments.CommentLatestRevision do

  use MoodleNet.Common.Schema
  alias MoodleNet.Comments.{Comment, CommentRevision, CommentLatestRevision}

  view_schema "mn_comment_latest_revision" do
    belongs_to :revision, CommentRevision, primary_key: true
    belongs_to :comment, Comment
    timestamps(updated_at: false)
  end

  @doc "Creates a fake CommentLatestRevision so we maintain ecto's format for linked data"
  def forge(%CommentRevision{id: revision_id, comment_id: comment_id, inserted_at: inserted_at}=revision) do
    %CommentLatestRevision{
      comment_id: comment_id,
      revision_id: revision_id,
      revision: revision,
      inserted_at: inserted_at,
    }
  end

end
