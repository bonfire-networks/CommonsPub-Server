# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.Test.Orderings do

  defp id(%{id: id}), do: id
  defp updated_at(%{updated_at: upd}), do: upd

  defp follower_count(item),
    do: Map.get(Map.get(item, :follower_count, %{}), :count, 0)

  def stable_sort_by(coll, []), do: coll
  def stable_sort_by(coll, [{fun, sort} | sorts]) do
    stable_sort_by(Enum.sort_by(coll, fun, sort), sorts)
  end

  def order_follower_count(coll) do
    stable_sort_by coll, [
      {&id/1,         :desc},
      {&updated_at/1, {:desc, DateTime}},
      {&follower_count/1, :desc}
    ]
  end

end
