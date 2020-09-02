defmodule CommonsPub.Web.Discussion.DiscussionCommentLive do
  use CommonsPub.Web, :live_component
  import CommonsPub.Utils.Web.CommonHelper

  alias CommonsPub.Web.Component.{
    CommentPreviewLive,
    PreviewActionsLive
  }

  alias CommonsPub.Web.Discussion.DiscussionCommentLive
  alias CommonsPub.Web.Discussion.DiscussionSubCommentLive
end
