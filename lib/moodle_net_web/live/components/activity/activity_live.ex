defmodule MoodleNetWeb.Component.ActivityLive do
  use Phoenix.LiveComponent

  import MoodleNetWeb.Helpers.Common

  alias MoodleNetWeb.Component.StoryPreviewLive
  alias MoodleNetWeb.Component.CommentPreviewLive
  alias MoodleNetWeb.Component.CommunityPreviewLive

  # alias MoodleNetWeb.Component.DiscussionPreviewLive

  alias MoodleNetWeb.Helpers.{Activites}

  def mount(activity, _session, socket) do
    {:ok, assign(socket, activity: activity)}
  end

  def update(assigns, socket) do
    if(Map.has_key?(assigns, :activity)) do
      {:ok,
       assign(socket,
         activity: Activites.prepare(assigns.activity)
       )}
    else
      {:ok, assign(socket, activity: %{})}
    end
  end
end
