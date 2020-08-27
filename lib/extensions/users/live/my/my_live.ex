defmodule MoodleNetWeb.My.MyLive do
  use MoodleNetWeb, :live_view

  import MoodleNetWeb.Helpers.Common

  # alias MoodleNetWeb.Helpers.{Profiles}

  alias MoodleNetWeb.My.TimelineLive

  alias MoodleNetWeb.Component.{
    # HeaderLive,
    TabNotFoundLive
  }

  def mount(params, session, socket) do
    socket = init_assigns(params, session, socket)

    {:ok,
     socket
     |> assign(
       page_title: "My " <> socket.assigns.app_name,
       selected_tab: "timeline",
       current_user: socket.assigns.current_user
     )}
  end

  def handle_params(%{"tab" => tab}, _url, socket) do
    {:noreply, assign(socket, selected_tab: tab)}
  end

  def handle_params(_, _url, socket) do
    {:noreply, assign(socket, selected_tab: "timeline")}
  end

  @doc """
  Forward PubSub activities in timeline to our timeline component
  """
  def handle_info({:pub_feed_activity, activity}, socket),
    do:
      MoodleNetWeb.Helpers.Activites.pubsub_activity_forward(
        activity,
        TimelineLive,
        :my_timeline,
        socket
      )

  defp link_body(name, icon) do
    assigns = %{name: name, icon: icon}

    ~L"""
      <i class="<%= @icon %>"></i>
      <%= @name %>
    """
  end
end
