defmodule CommonsPub.Web.Component.PreviewLive do
  use Phoenix.LiveComponent
  import CommonsPub.Web.Helpers.Common

  alias CommonsPub.Web.Component.StoryPreviewLive
  alias CommonsPub.Web.Component.CommentPreviewLive
  alias CommonsPub.Web.Component.LikePreviewLive
  alias CommonsPub.Web.Component.CommunityPreviewLive
  alias CommonsPub.Web.Component.CollectionPreviewLive
  alias CommonsPub.Web.Component.UnknownPreviewLive

  def render(assigns) do
    ~L"""
    <div id="preview-<%=@preview_id%>">
    <%= cond do
          @object_type == "community" ->
            live_component(
              @socket,
              CommunityPreviewLive,
              community: @object,
              current_user: @current_user,
              id: @preview_id
            )
          @object_type == "collection" ->
            live_component(
              @socket,
              CollectionPreviewLive,
              collection: @object,
              current_user: @current_user,
              id: @preview_id
            )
            @object_type == "user" ->
              live_component(
                @socket,
                CommonsPub.Web.Component.UserPreviewLive,
                user: @object,
                current_user: @current_user,
                id: @preview_id
              )
            @object_type == "comment" ->
              live_component(
                @socket,
                CommentPreviewLive,
                comment: @object,
                current_user: @current_user,
                id: @preview_id
              )
            @object_type == "like" ->
              live_component(
                @socket,
                LikePreviewLive,
                like: @object,
                current_user: @current_user,
                id: @preview_id
              )
            @object_type == "story" ->
              live_component(
                @socket,
                StoryPreviewLive,
                story: @object,
                current_user: @current_user,
                id: @preview_id
              )
            @object_type == "resource" ->
                live_component(
                  @socket,
                  CommonsPub.Web.Component.ResourcePreviewLive,
                  resource: @object,
                  current_user: @current_user,
                  id: @preview_id
                )
            @object_type == "flag" ->
              live_component(
                @socket,
                CommonsPub.Web.Component.FlagPreviewLive,
                flag: @object,
                current_user: @current_user,
                id: @preview_id
              )
            @object_type == "category" ->
              live_component(
                @socket,
                CommonsPub.Web.Component.CategoryPreviewLive,
                object: @object,
                current_user: @current_user,
                id: @preview_id
              )
            true ->
              live_component(
                @socket,
                UnknownPreviewLive,
                object: @object,
                current_user: @current_user,
                id: @preview_id
              )
          end
         %>
      </div>
    """
  end
end
