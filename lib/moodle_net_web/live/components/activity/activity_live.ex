defmodule MoodleNetWeb.Component.ActivityLive do
  use MoodleNetWeb, :live_component

  import MoodleNetWeb.Helpers.Common

  alias MoodleNetWeb.Component.PreviewLive

  # alias MoodleNetWeb.Component.DiscussionPreviewLive

  alias MoodleNetWeb.Helpers.{Activites}

  def update(assigns, socket) do
    if(Map.has_key?(assigns, :activity)) do
      reply_link =
        "/!" <>
          e(e(assigns.activity, :context, assigns.activity), :thread_id, "new") <>
          "/discuss/" <> e(e(assigns.activity, :context, assigns.activity), :id, "") <> "#reply"

      {:ok,
       assign(socket,
         activity: Activites.prepare(assigns.activity, assigns.current_user),
         current_user: assigns.current_user,
         reply_link: reply_link
       )}
    else
      {:ok,
       assign(socket,
         activity: %{},
         current_user: assigns.current_user
       )}
    end
  end

  def handle_event("like", _data, socket) do
    {:ok, like} =
      MoodleNetWeb.GraphQL.LikesResolver.create_like(
        %{context_id: e(e(socket.assigns.activity, :context, socket.assigns.activity), :id, nil)},
        %{
          context: %{current_user: socket.assigns.current_user}
        }
      )

    IO.inspect(like, label: "LIKE")

    # IO.inspect(f)
    # TODO: error handling

    {
      :noreply,
      socket
      |> put_flash(:info, "Liked!")
      |> assign(activity: socket.assigns.activity |> Map.merge(%{is_liked: true}))
      #  |> push_patch(to: "/&" <> socket.assigns.community.username)
    }
  end

  def handle_event("flag", %{"message" => message} = _args, socket) do
    {:ok, flag} =
      MoodleNetWeb.GraphQL.FlagsResolver.create_flag(
        %{
          context_id: e(e(socket.assigns.activity, :context, socket.assigns.activity), :id, nil),
          message: message
        },
        %{
          context: %{current_user: socket.assigns.current_user}
        }
      )

    IO.inspect(flag, label: "FLAG")

    # IO.inspect(f)
    # TODO: error handling

    {
      :noreply,
      socket
      |> put_flash(:info, "Flagged!")
      # |> assign(community: socket.assigns.comment |> Map.merge(%{is_liked: true}))
      #  |> push_patch(to: "/&" <> socket.assigns.community.username)
    }
  end
end
