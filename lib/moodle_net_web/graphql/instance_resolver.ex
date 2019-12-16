# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.InstanceResolver do

  alias MoodleNet.{Common, Fake, Features, GraphQL, Repo, Instance}
  alias MoodleNet.Collections.Collection
  alias MoodleNet.Communities.Community

  def instance(_, info) do
    hostname  = System.get_env("HOSTNAME")
    description = System.get_env("INSTANCE_DESCRIPTION")
    {:ok, %{hostname: hostname, description: description}}
  end

  def featured_communities(_, args, info) do
    Repo.transact_with(fn ->
      features = Features.list(%{contexts: [Community]})
      count = Enum.count(features)
      # count = Features.count_for_list(%{contexts: [Community]})
      {:ok, GraphQL.edge_list(features, count)}
    end)
  end

  def featured_collections(_, args, info) do
    Repo.transact_with(fn ->
      features = Features.list(%{contexts: [Collection]})
      count = Enum.count(features)
      # count = Features.count_for_list(%{contexts: [Collection]})
      {:ok, GraphQL.edge_list(features, count)}
    end)
  end

  def outbox(_, args, info) do
    Repo.transact_with(fn ->
      # activities =
      #   Instance.outbox()
      #   |> Enum.map(fn box -> %{cursor: box.id, node: box.activity} end)
      # count = Instance.count_for_outbox()
      activities = []
      count = 0
      page_info = Common.page_info(activities)
      {:ok, %{page_info: page_info, total_count: count, edges: activities}}
    end)
  end

end
