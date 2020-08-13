# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Likes.LikerCountsQueries do

  alias MoodleNet.Likes.LikerCount
  import Ecto.Query

  def query(LikerCount), do: from(l in LikerCount, as: :liker_count)

  def query(query, filters), do: filter(query(query), filters)

  @doc "Filter the query according to arbitrary criteria"
  def filter(query, filter_or_filters)

  def filter(q, filters) when is_list(filters), do: Enum.reduce(filters, q, &filter(&2, &1))

  def filter(q, {:count, {:gte, cnt}}) when is_integer(cnt) and cnt > 0, do: where(q, [liker_count: l], l.count >= ^cnt)
  def filter(q, {:count, {:lte, cnt}}) when is_integer(cnt) and cnt > 0, do: where(q, [liker_count: l], l.count <= ^cnt)

  def filter(q, {:context, id}) when is_binary(id), do: where(q, [liker_count: l], l.context_id == ^id)
  def filter(q, {:context, ids}) when is_list(ids), do: where(q, [liker_count: l], l.context_id in ^ids)

end
