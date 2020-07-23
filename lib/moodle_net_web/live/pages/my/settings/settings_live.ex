defmodule MoodleNetWeb.SettingsLive do
  use MoodleNetWeb, :live_view

  import MoodleNetWeb.Helpers.Common
  # alias MoodleNetWeb.Helpers.{Profiles}
  alias MoodleNetWeb.GraphQL.UsersResolver

  alias MoodleNetWeb.SettingsLive.{
    SettingsNavigationLive,
    SettingsGeneralLive,
    SettingsInstanceLive,
    SettingsFlagsLive,
    SettingsInvitesLive
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
       selected_tab: "general",
       trigger_submit: false
       #  current_user: user,
       #  session: session_token
     )}
  end

  def handle_params(%{"tab" => tab}, _url, socket) do
    {:noreply, assign(socket, selected_tab: tab)}
  end

  def handle_params(_, _url, socket) do
    {:noreply, socket}
  end

  def handle_event("profile_save", data, %{assigns: %{trigger_submit: trigger_submit}} = socket)
      when trigger_submit == true do
    {
      :noreply,
      assign(socket, trigger_submit: false)
    }
  end

  def handle_event("profile_save", data, socket) do
    params = input_to_atoms(data)
    IO.inspect(params)

    {:ok, _edit_profile} =
      UsersResolver.update_profile(params, %{
        context: %{current_user: socket.assigns.current_user}
      })

    cond do
      strlen(params.icon) > 0 or strlen(params.image) > 0 ->
        {
          :noreply,
          assign(socket, trigger_submit: true)
          |> put_flash(:info, "Details saved!")
          #  |> push_redirect(to: "/~/profile")
        }

      true ->
        IO.inspect("without file")

        {:noreply,
         socket
         |> put_flash(:info, "Profile saved!")
         |> push_redirect(to: "/~/profile")}
    end
  end

  def upload_files(conn) do
    IO.inspect("upload!")
  end

  # def handle_params(%{} = params, url, socket) do
  #   user = Profiles.user_load(socket, params, %{image: true, icon: true, actor: true})

  #   {:noreply,
  #    assign(socket,
  #      user: user
  #    )}
  # end
end
