defmodule CommonsPub.Web.Discussion.DiscussionCommentLive do
  use CommonsPub.Web, :live_component


  alias CommonsPub.Web.Component.{
    CommentPreviewLive,
    PreviewActionsLive
  }

  alias CommonsPub.Web.Discussion.DiscussionCommentLive
  alias CommonsPub.Web.Discussion.DiscussionSubCommentLive
end
