# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Follows.FollowCountsQueries do

  alias MoodleNet.Follows.FollowCount

  import Ecto.Query

  def query(FollowCount) do
    from f in FollowCount, as: :follow_count
  end

  def query(query, filters), do: filter(query(query), filters)

  @doc "Filter the query according to arbitrary criteria"
  def filter(q, filter_or_filters)

  ## by many

  def filter(q, filters) when is_list(filters) do
    Enum.reduce(filters, q, &filter(&2, &1))
  end

  # by field values

  def filter(q, {:creator, id}) when is_binary(id) do
    where q, [follow_count: f], f.creator_id == ^id
  end

  def filter(q, {:creator, ids}) when is_list(ids) do
    where q, [follow_count: f], f.creator_id in ^ids
  end

end
