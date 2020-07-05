defmodule MoodleNetWeb.Component.HeaderLive do
  use Phoenix.LiveComponent

  import MoodleNetWeb.Helpers.Common

  alias MoodleNetWeb.GraphQL.{
    UsersResolver
  }

  alias MoodleNetWeb.Helpers.{Profiles}

  def mount(socket) do
    {:ok,
     socket
     |> assign(
       app_name: Application.get_env(:moodle_net, :app_name),
       app_icon: Application.get_env(:moodle_net, :app_icon, "/images/sun_face.png")
     )}
  end

  # def update(assigns, socket) do
  #   # IO.inspect(assigns)
  #   # TODO: use logged in user here
  #   user = Profiles.user_load(socket, assigns, %{icon: true, actor: true})
  #   {:ok, assign(socket, user: user)}
  # end
end
