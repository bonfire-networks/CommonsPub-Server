defmodule CommonsPub.Web.Component.ActivityLive do
  use CommonsPub.Web, :live_component

  import CommonsPub.Web.Helpers.Common

  alias CommonsPub.Web.Component.{PreviewLive, PreviewActionsLive, PreviewActionsAdminLive}

  # alias CommonsPub.Web.Component.DiscussionPreviewLive

  alias CommonsPub.Web.Helpers.{Activites}

  def update(assigns, socket) do
    activity_id = e(assigns, :activity, :id, random_string(6))
    preview_id = activity_id <> "-" <> e(assigns, :activity, :context, :id, random_string(6))

    if(Map.has_key?(assigns, :activity) and assigns.activity != %{}) do
      activity = Activites.prepare(assigns.activity, assigns.current_user)

      reply_link =
        "/!" <>
          e(e(activity, :context, activity), :thread_id, "new") <>
          "/discuss/" <> e(e(activity, :context, activity), :id, "") <> "#reply"

      {:ok,
       assign(socket,
         activity: activity,
         current_user: assigns.current_user,
         reply_link: reply_link,
         #  creator_link: creator_link,
         activity_id: activity_id,
         preview_id: preview_id
       )}
    else
      {:ok,
       assign(socket,
         activity: %{},
         current_user: assigns.current_user,
         reply_link: "#",
         #  creator_link: "#",
         activity_id: activity_id,
         preview_id: preview_id
       )}
    end
  end
end
