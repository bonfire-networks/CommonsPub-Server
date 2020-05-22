# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Likes.LikeCountsQueries do

  alias MoodleNet.Likes.LikeCount
  import Ecto.Query

  def query(LikeCount), do: from(l in LikeCount, as: :like_count)

  def query(query, filters), do: filter(query(query), filters)

  @doc "Filter the query according to arbitrary criteria"
  def filter(q, filter_or_filters)

  def filter(q, filters) when is_list(filters), do: Enum.reduce(filters, q, &filter(&2, &1))

  def filter(q, {:creator, id}) when is_binary(id), do: where(q, [like_count: l], l.creator_id == ^id)
  def filter(q, {:creator, ids}) when is_list(ids), do: where(q, [like_count: l], l.creator_id in ^ids)

  def filter(q, {:count, {:gte, cnt}}) when is_integer(cnt) and cnt > 0, do: where(q, [like_count: l], l.count >= ^cnt)
  def filter(q, {:count, {:lte, cnt}}) when is_integer(cnt) and cnt > 0, do: where(q, [like_count: l], l.count <= ^cnt)

end
