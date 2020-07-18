defmodule MoodleNetWeb.Discussion.DiscussionCommentLive do
  use MoodleNetWeb, :live_component
  import MoodleNetWeb.Helpers.Common

  alias MoodleNetWeb.Component.{
    CommentPreviewLive
  }

  alias MoodleNetWeb.Discussion.DiscussionCommentLive
  alias MoodleNetWeb.Discussion.DiscussionSubCommentLive
end
