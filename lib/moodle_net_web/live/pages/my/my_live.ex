defmodule MoodleNetWeb.My.Live do
  use MoodleNetWeb, :live_view

  import MoodleNetWeb.Helpers.Common
  alias MoodleNetWeb.Helpers.{Profiles}

  alias MoodleNetWeb.My.TimelineLive

  alias MoodleNetWeb.Component.{
    HeaderLive,
    TabNotFoundLive
  }

  def mount(_params, session, socket) do
    app_name = Application.get_env(:moodle_net, :app_name)
    with {:ok, session_token} <- MoodleNet.Access.fetch_token_and_user(session["auth_token"])
    do
      {:ok,
     socket
     |> assign(
      page_title: "My " <> app_name,
      selected_tab: "timeline",
      app_name: Application.get_env(:moodle_net, :app_name),
      current_user: Profiles.prepare(session_token.user, %{icon: true, actor: true})
     )}
    else
      {:error, _} ->
        {:ok,
      socket
      |> assign(
        page_title: "My " <> app_name,
      selected_tab: "timeline",
      app_name: Application.get_env(:moodle_net, :app_name),
      current_user: nil
      )}
    end

  end

  def handle_params(%{"tab" => tab}, _url, socket) do
    {:noreply, assign(socket, selected_tab: tab)}
  end

  def handle_params(_, _url, socket) do
    {:noreply, socket}
  end

  defp link_body(name, icon) do
    assigns = %{name: name, icon: icon}

    ~L"""
      <i class="<%= @icon %>"></i>
      <%= @name %>
    """
  end
end
