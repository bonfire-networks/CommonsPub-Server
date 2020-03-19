# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Follows.FollowerCounts do
  alias MoodleNet.Repo
  alias MoodleNet.Batching.Edges
  alias MoodleNet.Follows.{FollowerCount, FollowerCountsQueries}

  def one(filters), do: Repo.single(FollowerCountsQueries.query(FollowerCount, filters))

  def many(filters \\ []) do
    {:ok, Repo.all(FollowerCountsQueries.query(FollowerCount, filters))}
  end

  def edges(group_fn, filters \\ [])
  when is_function(group_fn, 1) do
    {:ok, edges} = many(filters)
    {:ok, Edges.new(edges, group_fn)}
  end

end
