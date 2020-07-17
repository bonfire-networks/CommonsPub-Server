defmodule MoodleNetWeb.Component.PreviewLive do
  use Phoenix.LiveComponent
  import MoodleNetWeb.Helpers.Common

  alias MoodleNetWeb.Component.StoryPreviewLive
  alias MoodleNetWeb.Component.CommentPreviewLive
  alias MoodleNetWeb.Component.LikePreviewLive
  alias MoodleNetWeb.Component.CommunityPreviewLive
  alias MoodleNetWeb.Component.UnknownPreviewLive

  def render(assigns) do
    ~L"""
    <%=
      cond do
          @object_type == "community" ->
            live_component(
              @socket,
              CommunityPreviewLive,
              community: @object,
              current_user: @current_user,
              id: @object.id
            )
            @object_type == "comment" ->
              live_component(
                @socket,
                CommentPreviewLive,
                comment: @object,
                current_user: @current_user,
                id: @object.id
              )
            @object_type == "like" ->
              live_component(
                @socket,
                LikePreviewLive,
                comment: @object,
                current_user: @current_user,
                id: @object.id
              )
            @object_type == "story" ->
              live_component(
                @socket,
                StoryPreviewLive,
                story: @object,
                current_user: @current_user,
                id: @object.id
              )
            true ->
              live_component(
                @socket,
                UnknownPreviewLive,
                object: @object,
                current_user: @current_user,
                id: e(@object, :id, nil)
              )
          end
         %>
    """
  end
end
