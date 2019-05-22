defmodule MoodleNet.Application do
  @moduledoc """
  MoodleNet Application
  """
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    :telemetry.attach(
      "appsignal-ecto",
      [:moodle_net, :repo, :query],
      &Appsignal.Ecto.handle_event/4,
      nil
    )

    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
      supervisor(MoodleNet.Repo, []),
      # Start the endpoint when the application starts
      supervisor(MoodleNetWeb.Endpoint, [])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MoodleNet.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
