defmodule MoodleNetWeb.AdminLive do
  use MoodleNetWeb, :live_view

  import MoodleNetWeb.Helpers.Common
  alias MoodleNetWeb.GraphQL.{UsersResolver, AccessResolver}
  alias MoodleNetWeb.AdminLive.{
    AdminNavigationLive,
    AdminInstanceLive,
    AdminAccessLive,
    AdminFlagsLive,
    AdminInvitesLive
  }

  alias MoodleNetWeb.Component.{
    TabNotFoundLive
  }

  def mount(params, session, socket) do
    IO.inspect(session)
    socket = init_assigns(params, session, socket)

    {:ok,
     socket
     |> assign(
       page_title: "Settings",
       selected_tab: "access",
       selected_sub: "all",
       trigger_submit: false
       #  current_user: user,
       #  session: session_token
     )}
  end

  def handle_params(%{"sub" => sub, "tab" => tab} = params, _url, socket) do
    IO.inspect(sub, label: "sub")
    {:noreply,
     assign(socket,
       selected_sub: sub,
       current_user: socket.assigns.current_user
     )}
  end

  def handle_params(%{"tab" => tab} = params, _url, socket) do
    IO.inspect(params, label: "params")
    {:noreply,
     assign(socket,
       selected_tab: tab,
       current_user: socket.assigns.current_user
     )}
  end



  def handle_params(%{} = params, _url, socket) do
    {:noreply,
     assign(socket,
       current_user: socket.assigns.current_user
     )}
  end









  # def handle_params(%{} = params, url, socket) do
  #   user = Profiles.user_load(socket, params, %{image: true, icon: true, actor: true})

  #   {:noreply,
  #    assign(socket,
  #      user: user
  #    )}
  # end
end
