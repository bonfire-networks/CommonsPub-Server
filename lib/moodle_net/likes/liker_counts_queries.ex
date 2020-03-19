# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Likes.LikerCountsQueries do

  alias MoodleNet.Likes.LikerCount

  import Ecto.Query

  def query(LikerCount) do
    from l in LikerCount, as: :liker_count
  end

  def query(query, filters), do: filter(query(query), filters)

  @doc "Filter the query according to arbitrary criteria"
  def filter(q, filter_or_filters)

  ## by many

  def filter(q, filters) when is_list(filters) do
    Enum.reduce(filters, q, &filter(&2, &1))
  end

  # by field values

  def filter(q, {:context_id, id}) when is_binary(id) do
    where q, [liker_count: l], l.context_id == ^id
  end

  def filter(q, {:context_id, ids}) when is_list(ids) do
    where q, [liker_count: l], l.context_id in ^ids
  end

end
