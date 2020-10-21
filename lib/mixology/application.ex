# SPDX-License-Identifier: AGPL-3.0-only
defmodule CommonsPub.Application do
  @moduledoc """
  CommonsPub Application
  """
  use Application
  alias CommonsPub.Repo
  # alias CommonsPub.Locales.{CountryService, LanguageService}
  alias CommonsPub.Meta.TableService
  alias CommonsPub.Web.Endpoint
  import Supervisor.Spec, only: [supervisor: 2, worker: 2]

  @name Mix.Project.config()[:name]
  @version Mix.Project.config()[:version]
  @repository Mix.Project.config()[:source_url]

  def name, do: @name
  def version, do: @version
  def named_version, do: @name <> " " <> @version
  def repository, do: @repository

  def start(_type, _args) do
    # start repos, run migrations, stop repos
    CommonsPub.ReleaseTasks.startup_migrations()

    {:ok, _} = Logger.add_backend(Sentry.LoggerBackend)
    :ok = Oban.Telemetry.attach_default_logger(:debug)

    :ok =
      :telemetry.attach(
        "oban-logger",
        [:oban, :job, :exception],
        &CommonsPub.Workers.ObanLogger.handle_event/4,
        nil
      )

    # TODO: better supervision tree. LS, CS and TS only need repo on
    # startup, never need restarting, but they should require repo to
    # start, endpoint should attempt to serve users without the repo
    # and does not need it to start up
    children = [
      CommonsPub.Utils.Metrics,
      supervisor(Repo, []),
      worker(TableService, []),
      {Phoenix.PubSub, [name: CommonsPub.PubSub, adapter: Phoenix.PubSub.PG2]},
      supervisor(Endpoint, []),
      {Oban, CommonsPub.Config.get(Oban)}
    ]

    opts = [strategy: :one_for_one, name: CommonsPub.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
