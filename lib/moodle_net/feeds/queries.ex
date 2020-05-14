# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Feeds.Queries do

  alias MoodleNet.Feeds.Feed
  import Ecto.Query

  def query(Feed), do: from(f in Feed, as: :feed)

  def query(query, filters), do: filter(query(query), filters)

  def filter(query, filter_or_filters)
  def filter(q, filters) when is_list(filters), do: Enum.reduce(filters, q, &filter(&2, &1))

  def filter(q, {:id, id}) when is_binary(id), do: where(q, [feed: f], f.id == ^id)
  def filter(q, {:id, {:gte, id}}) when is_binary(id), do: where(q, [feed: f], f.id >= ^id)
  def filter(q, {:id, {:lte, id}}) when is_binary(id), do: where(q, [feed: f], f.id <= ^id)
  def filter(q, {:id, ids}) when is_list(ids), do: where(q, [feed: f], f.id in ^ids)

  def filter(q, {:deleted, nil}), do: where(q, [feed: f], is_nil(f.deleted_at))
  def filter(q, {:deleted, :not_nil}), do: where(q, [feed: f], not is_nil(f.deleted_at))
  def filter(q, {:deleted, false}), do: where(q, [feed: f], is_nil(f.deleted_at))
  def filter(q, {:deleted, true}), do: where(q, [feed: f], not is_nil(f.deleted_at))
  def filter(q, {:deleted, {:gte, %DateTime{}=time}}), do: where(q, [feed: f], f.deleted_at >= ^time)
  def filter(q, {:deleted, {:lte, %DateTime{}=time}}), do: where(q, [feed: f], f.deleted_at <= ^time)

  def filter(q, {:select, :id}), do: select(q, [feed: f], f.id)

end
