# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Feeds.Queries do

  alias MoodleNet.Feeds.Feed
  import Ecto.Query

  def query(Feed) do
    from f in Feed, as: :feed
  end

  def query(query, filters), do: filter(query(query), filters)

  ## by many

  def filter(q, filters) when is_list(filters) do
    Enum.reduce(filters, q, &filter(&2, &1))
  end

  ## by field values

  def filter(q, {:id, ids}) when is_list(ids) do
    where q, [collection: c], c.id in ^ids
  end

end
