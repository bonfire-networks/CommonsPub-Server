defmodule MoodleNetWeb.Component.PreviewActionsAdminLive do
  use MoodleNetWeb, :live_component

  import MoodleNetWeb.Helpers.Common

  alias MoodleNetWeb.Component.{FlagLive}

  # alias MoodleNetWeb.Helpers.{Activites}

  def update(assigns, socket) do
    is_liked = is_liked(assigns.current_user, e(assigns, :object, :id, nil))

    reply_link =
      "/!" <>
        e(assigns.object, :thread_id, "new") <>
        "/discuss/" <> e(assigns.object, :id, "") <> "#reply"

    {:ok,
     assign(socket,
       current_user: assigns.current_user,
       object: assigns.object,
       reply_link: reply_link,
       is_liked: is_liked,
       preview_id: assigns.preview_id
     )}
  end

  def handle_event("like", _data, socket) do
    {:ok, like} =
      MoodleNetWeb.GraphQL.LikesResolver.create_like(
        %{context_id: e(socket.assigns.object, :id, nil)},
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
      |> assign(is_liked: true)
      #  |> push_patch(to: "/&" <> socket.assigns.community.username)
    }
  end

  def handle_event("flag", %{"message" => message} = _args, socket) do
    {:ok, flag} =
      MoodleNetWeb.GraphQL.FlagsResolver.create_flag(
        %{
          context_id: e(socket.assigns.object, :id, nil),
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
