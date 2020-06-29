defmodule MoodleNetWeb.InstanceLive do
  use MoodleNetWeb, :live_view
  alias MoodleNetWeb.Helpers.{Profiles}
  import MoodleNetWeb.Helpers.Common

  alias MoodleNetWeb.Component.{
    HeaderLive,
    AboutLive,
    TabNotFoundLive
  }

  alias MoodleNetWeb.InstanceLive.{
    InstanceActivitiesLive,
    InstanceMembersLive
  }

  def mount(params, session, socket) do
    with {:ok, session_token} <- MoodleNet.Access.fetch_token_and_user(session["auth_token"])
    do
      {:ok,
     socket
     |> assign(
       page_title: "Home",
       hostname: MoodleNet.Instance.hostname(),
       description: MoodleNet.Instance.description(),
       selected_tab: "about",
       current_user: Profiles.prepare(session_token.user, %{icon: true, actor: true})
     )}
    else
      {:error, _} ->
        {:ok,
      socket
      |> assign(
        page_title: "Home",
        hostname: MoodleNet.Instance.hostname(),
        description: MoodleNet.Instance.description(),
        selected_tab: "about",
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
