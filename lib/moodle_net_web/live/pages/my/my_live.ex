defmodule MoodleNetWeb.My.Live do
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
    app_name = Application.get_env(:moodle_net, :app_name)

    {:ok,
     socket
     |> assign(
       page_title: "My " <> app_name,
       selected_tab: "timeline",
       app_name: Application.get_env(:moodle_net, :app_name),
       current_user: socket.assigns.current_user
     )}
  end

  def handle_params(%{"tab" => tab}, _url, socket) do
    {:noreply, assign(socket, selected_tab: tab)}
  end

  def handle_params(_, _url, socket) do
    {:noreply, assign(socket, selected_tab: "timeline")}
  end

  defp link_body(name, icon) do
    assigns = %{name: name, icon: icon}

    ~L"""
      <i class="<%= @icon %>"></i>
      <%= @name %>
    """
  end
end
