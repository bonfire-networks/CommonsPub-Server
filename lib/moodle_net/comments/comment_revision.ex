defmodule MoodleNet.Comments.CommentRevision do
  use MoodleNet.Common.Schema

  standalone_schema "mn_comment_revision" do
    belongs_to(:comment, Comment)
    field(:content, :string)
    timestamps(updated_at: false)
  end
end
