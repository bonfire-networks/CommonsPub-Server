# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule ActivityPub.HTTP.Connection do
  @hackney_options [
    connect_timeout: 10_000,
    recv_timeout: 20_000,
    follow_redirect: true,
    pool: :federation
  ]
  @adapter Application.get_env(:tesla, :adapter)

  def new(opts \\ []) do
    Tesla.client([], {@adapter, hackney_options(opts)})
  end

  defp hackney_options(opts) do
    options = Keyword.get(opts, :adapter, [])

    @hackney_options
    |> Keyword.merge(options)
  end
end