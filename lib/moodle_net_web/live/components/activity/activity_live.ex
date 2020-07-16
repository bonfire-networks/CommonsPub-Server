defmodule MoodleNetWeb.Component.ActivityLive do
  use MoodleNetWeb, :live_component

  import MoodleNetWeb.Helpers.Common

  alias MoodleNetWeb.Component.StoryPreviewLive
  alias MoodleNetWeb.Component.CommentPreviewLive
  alias MoodleNetWeb.Component.CommunityPreviewLive

  # alias MoodleNetWeb.Component.DiscussionPreviewLive

  alias MoodleNetWeb.Helpers.{Activites}


  def update(assigns, socket) do
    if(Map.has_key?(assigns, :activity)) do
      {:ok,
       assign(socket,
         activity: Activites.prepare(assigns.activity),
         current_user: assigns.current_user
       )}
    else
      {:ok, assign(socket,
        activity: %{},
        current_user: assigns.current_user)}
    end
  end
end
