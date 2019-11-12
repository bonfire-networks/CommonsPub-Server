# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.InstanceResolver do

  alias MoodleNet.{Fake, GraphQL}

  def instance(_, info) do
    {:ok, %{}}
  end

  def outbox(_, args, info) do
    count = Fake.pos_integer()
    activities = Fake.long_list(&Fake.activity/0)
    {:ok, GraphQL.node_list(activities, count)}
    |> GraphQL.response(info)
  end

end
