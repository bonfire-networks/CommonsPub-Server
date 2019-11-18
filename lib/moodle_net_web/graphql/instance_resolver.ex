# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.InstanceResolver do

  alias MoodleNet.{Fake, GraphQL}

  def instance(_, info) do
    hostname  = System.get_env("HOSTNAME")
    description = System.get_env("INSTANCE_DESCRIPTION")
    {:ok, %{hostname: hostname, description: description}}
  end

  def outbox(_, args, info) do
    {:ok, Fake.long_edge_list(&Fake.activity/0)}
    |> GraphQL.response(info)
  end

end
