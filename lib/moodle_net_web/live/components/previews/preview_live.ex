defmodule MoodleNetWeb.Component.PreviewLive do
  use Phoenix.LiveComponent
  import MoodleNetWeb.Helpers.Common

  alias MoodleNetWeb.Component.StoryPreviewLive
  alias MoodleNetWeb.Component.CommentPreviewLive
  alias MoodleNetWeb.Component.LikePreviewLive
  alias MoodleNetWeb.Component.CommunityPreviewLive
  alias MoodleNetWeb.Component.CollectionPreviewLive
  alias MoodleNetWeb.Component.UnknownPreviewLive

  def render(assigns) do
    ~L"""
    <div id="preview-<%=@preview_id%>">
    <%=
      IO.inspect(preview_object_type: @object_type)
      # IO.inspect(preview_object: @object)
      cond do
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
            @object_type == "flag" ->
              live_component(
                @socket,
                MoodleNetWeb.Component.FlagPreviewLive,
                flag: @object,
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
