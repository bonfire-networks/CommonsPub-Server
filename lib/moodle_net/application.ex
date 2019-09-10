# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNet.Application do
  @moduledoc """
  MoodleNet Application
  """
  use Application
  alias MoodleNet.Repo
  alias MoodleNet.Meta.TableService
  alias MoodleNetWeb.Endpoint
  import Supervisor.Spec, only: [supervisor: 2, worker: 2]

  def start(_type, _args) do

    {:ok, _} = Logger.add_backend(Sentry.LoggerBackend)

    children = [
      supervisor(Repo, []),
      worker(TableService, []),
      supervisor(Endpoint, []),
    ]

    opts = [strategy: :rest_for_one, name: MoodleNet.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
