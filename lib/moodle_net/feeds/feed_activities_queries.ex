# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Feeds.FeedActivitiesQueries do
  use MoodleNet.Common.Metadata
  alias MoodleNet.Activities
  alias MoodleNet.Feeds.FeedActivity
  import MoodleNet.Common.Query, only: [match_admin: 0]
  import Ecto.Query

  # we will probably never want to not prefetch these
  def query(FeedActivity) do
    from f in FeedActivity, as: :feed_activity,
      join: a in assoc(f, :activity), as: :activity,
      join: c in assoc(a, :context), as: :context,
      preload: [activity: {a, context: c}]
  end

  def query(query, filters), do: filter(query(query), filters)

  def queries(query, base_filters, data_filters, count_filters) do
    base_q = query(query, base_filters)
    data_q = filter(base_q, data_filters)
    count_q = filter(base_q, count_filters)
    {data_q, count_q}
  end

  ### filter/2

  @will_break_when :privacy # determine when a user can see items

  ## by many

  def filter(q, filters) when is_list(filters) do
    Enum.reduce(filters, q, &filter(&2, &1))
  end

  ## by user

  def filter(q, {:user, match_admin()}), do: Activities.Queries.filter(q, :deleted)

  # Guest or ordinary user are currently not treated differently
  def filter(q, {:user, _}), do: Activities.Queries.filter(q, ~w(deleted private))

  ## by field values

  def filter(q, {:id, id}) when is_binary(id) do
    where q, [feed_activity: fa], fa.id == ^id
  end

  def filter(q, {:id, ids}) when is_list(ids) do
    where q, [feed_activity: fa], fa.id in ^ids
  end

  def filter(q, {:feed_id, id}) when is_binary(id) do
    where q, [feed_activity: fa], fa.feed_id == ^id
  end

  def filter(q, {:feed_id, ids}) when is_list(ids) do
    where q, [feed_activity: fa], fa.feed_id in ^ids
  end

  def filter(q, {:activity_id, id}) when is_binary(id) do
    where q, [feed_activity: fa], fa.activity_id == ^id
  end

  def filter(q, {:activity_id, ids}) when is_list(ids) do
    where q, [feed_activity: fa], fa.activity_id in ^ids
  end

  def filter(q, {:order, :timeline}) do
    order_by q, [feed_activity: fa], [desc: fa.id]
  end

end
