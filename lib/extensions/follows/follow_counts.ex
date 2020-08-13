# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Follows.FollowCounts do
  alias MoodleNet.Repo
  alias MoodleNet.Follows.{FollowCount, FollowCountsQueries}
  alias MoodleNet.GraphQL.Fields

  def one(filters), do: Repo.single(FollowCountsQueries.query(FollowCount, filters))

  def many(filters \\ []) do
    {:ok, Repo.all(FollowCountsQueries.query(FollowCount, filters))}
  end

  def fields(group_fn, filters \\ [])
  when is_function(group_fn, 1) do
    {:ok, fields} = many(filters)
    Fields.new(fields, group_fn)
  end

end
