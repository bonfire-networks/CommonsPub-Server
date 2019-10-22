# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Application do
  @moduledoc """
  MoodleNet Application
  """
  use Application
  alias MoodleNet.Repo
  alias MoodleNet.Localisation.{CountryService, LanguageService}
  alias MoodleNet.Meta.TableService
  alias MoodleNetWeb.Endpoint
  import Supervisor.Spec, only: [supervisor: 2, worker: 2]

  def start(_type, _args) do

    {:ok, _} = Logger.add_backend(Sentry.LoggerBackend)

    # TODO: better supervision tree. LS, CS and TS only need repo on
    # startup, never need restarting, but they should require repo to
    # start, endpoint should attempt to serve users without the repo
    # and does not need it to start up
    children = [
      supervisor(Repo, []),
      worker(LanguageService, []),
      worker(CountryService, []),
      worker(TableService, []),
      supervisor(Endpoint, []),
    ]

    opts = [strategy: :one_for_one, name: MoodleNet.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
