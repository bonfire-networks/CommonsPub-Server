# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Follows.FollowerCountsQueries do

  alias MoodleNet.Follows.FollowerCount

  import Ecto.Query

  def query(FollowerCount) do
    from f in FollowerCount, as: :follower_count
  end

  def query(query, filters), do: filter(query(query), filters)

  @doc "Filter the query according to arbitrary criteria"
  def filter(q, filter_or_filters)

  ## by many

  def filter(q, filters) when is_list(filters) do
    Enum.reduce(filters, q, &filter(&2, &1))
  end

  # by field values

  def filter(q, {:context, id}) when is_binary(id) do
    where q, [follower_count: f], f.context_id == ^id
  end

  def filter(q, {:context, ids}) when is_list(ids) do
    where q, [follower_count: f], f.context_id in ^ids
  end

end
