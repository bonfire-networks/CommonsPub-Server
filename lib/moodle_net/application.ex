# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNet.Application do
  @moduledoc """
  MoodleNet Application
  """
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    {:ok, _} = Logger.add_backend(Sentry.LoggerBackend)

    children = [
      supervisor(MoodleNet.Repo, []),
      supervisor(MoodleNetWeb.Endpoint, [])
    ]

    opts = [strategy: :one_for_one, name: MoodleNet.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
