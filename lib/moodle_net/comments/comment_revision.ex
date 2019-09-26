# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Comments.CommentRevision do
  use MoodleNet.Common.Schema
  alias MoodleNet.Comments.Comment

  standalone_schema "mn_comment_revision" do
    belongs_to(:comment, Comment)
    field(:content, :string)
    timestamps(updated_at: false)
  end

end
