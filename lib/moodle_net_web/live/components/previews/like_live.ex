defmodule MoodleNetWeb.Component.LikePreviewLive do
  use Phoenix.LiveComponent
  import MoodleNetWeb.Helpers.{Common}
  alias MoodleNetWeb.Helpers.Discussions
  alias MoodleNetWeb.Helpers.{Activites}
  alias MoodleNetWeb.Component.ActivityLive

  # def update(assigns, socket) do
  #   like = prepare_context(assigns.like)

  #   {:ok,
  #    socket
  #    |> assign(
  #      like: like
  #      #  current_user: socket.assigns.current_user
  #    )}
  # end

  def render(assigns) do
    ~L"""
      <%=
        like = prepare_context(@like)
        # IO.inspect(preview_like: like)

        live_component(
            @socket,
            ActivityLive,
            activity: like.context |> Map.merge(%{context_type: like.context_type}),
            current_user: e(@current_user, %{}),
          )
      %>
    """
  end
end
