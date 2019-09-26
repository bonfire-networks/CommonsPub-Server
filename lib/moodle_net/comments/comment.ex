defmodule MoodleNet.Comments.Comment do

  use MoodleNet.Common.Schema
  alias MoodleNet.Comments.{Comment, CommentRevision, CommentLatestRevision}

  meta_schema "mn_comment" do
    has_many :revisions, CommentRevision
    has_one :latest_revision, CommentLatestRevision
    has_one :current, through: [:latest_revision, :revision]
  end

end
