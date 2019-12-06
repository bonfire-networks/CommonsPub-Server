# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Common.Query do

  import Ecto.Query

  def unroll(items, key \\ :context)
  def unroll(items, key) when is_list(items), do: Enum.map(&unroll(&1, key))
  def unroll({l,r}, key), do: %{ l | key => r}

  def count(query) do
    select(query, [q], count(q))
  end

  def only_public(query) do
    where(query, [q], not is_nil(q.published_at))
  end
  
  def only_undeleted(query) do
    where(query, [q], is_nil(q.deleted_at))
  end
  
  def order_by_recently_updated(query) do
    order_by(query, desc: :updated_at)
  end

end
