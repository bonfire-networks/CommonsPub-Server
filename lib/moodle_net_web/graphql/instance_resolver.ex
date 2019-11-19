# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.InstanceResolver do

  alias MoodleNet.{Fake, GraphQL, Instance}

  def instance(_, info) do
    hostname  = System.get_env("HOSTNAME")
    description = System.get_env("INSTANCE_DESCRIPTION")
    {:ok, %{hostname: hostname, description: description}}
  end

  def outbox(_, args, info) do
    Repo.transact_with(fn ->
      activities =
        Instance.outbox()
        |> Enum.map(fn box -> %{cursor: box.id, node: box.activity} end)
      count = Instance.count_for_outbox()
      page_info = Common.page_info(activities)
      {:ok, %{page_info: page_info, total_count: count, edges: activities}}
    end)
  end

end
