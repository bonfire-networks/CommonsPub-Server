defmodule MoodleNetWeb.SignupLive do
  use MoodleNetWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(
       app_name: Application.get_env(:moodle_net, :app_name),
       app_icon: Application.get_env(:moodle_net, :app_icon, "/images/sun_face.png")
     )}
  end

end
