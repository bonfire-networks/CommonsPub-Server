defmodule MoodleNetWeb.Discussion.DiscussionCommentLive do
  use MoodleNetWeb, :live_component
  import MoodleNetWeb.Helpers.Common
  alias MoodleNetWeb.GraphQL.{ThreadsResolver, CommentsResolver}
  alias MoodleNetWeb.Helpers.{Account, Discussions}
  alias MoodleNetWeb.Component.{CommentPreviewLive, ActivityLive}


end
