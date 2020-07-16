defmodule MoodleNetWeb.SearchLive do
  use MoodleNetWeb, :live_view

  alias MoodleNetWeb.Component.{
    TabNotFoundLive
  }

  import MoodleNetWeb.Helpers.Common

  def mount(params, session, socket) do
    socket = init_assigns(params, session, socket)
    IO.inspect(params, label: "PARAMS")

    {:ok,
     socket
     |> assign(
       page_title: "Search",
       me: false,
       current_user: socket.assigns.current_user,
       selected_tab: "users",
       search: ""
     )}
  end

  def handle_params(%{"tab" => tab} = params, _url, socket) do
    # IO.inspect(community, label: "COMMUNITY")
    IO.inspect(tab, label: "TAB")

    {:noreply,
     assign(socket,
       selected_tab: tab
       #  current_user: socket.assigns.current_user
     )}
  end

  def handle_params(params, _url, socket) do
    # community =
    # Communities.community_load(socket, params, %{icon: true, image: true, actor: true})

    # IO.inspect(community, label: "community")

    {:noreply,
     assign(socket,
       #  community: community,
       current_user: socket.assigns.current_user
     )}
  end

  defp link_body(name, icon) do
    assigns = %{name: name, icon: icon}

    ~L"""
      <i class="<%= @icon %>"></i>
      <%= @name %>
    """
  end
end
