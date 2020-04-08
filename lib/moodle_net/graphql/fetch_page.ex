# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.GraphQL.FetchPage do
  @enforce_keys [:queries, :query, :cursor_fn, :page_opts]
  defstruct [
    :queries,
    :query,
    :cursor_fn,
    :page_opts,
    base_filters: [],
    data_filters: [],
    count_filters: [],
    count_with: :count,
    map_fn: nil,
    map_count_fn: nil,
  ]

  alias MoodleNet.Repo
  alias MoodleNet.GraphQL.{Page, FetchPage}

  @type t :: %FetchPage{
    queries: atom,
    query: atom,
    cursor_fn: (term -> term),
    page_opts: map,
    base_filters: list,
    data_filters: list,
    count_filters: list,
    count_with: :count | :all,
    map_fn: (term -> term) | nil,
    map_count_fn: (term -> term) | nil,
  }

  def run(
    %FetchPage{
      queries: queries,
      query: query,
      cursor_fn: cursor_fn,
      page_opts: page_opts,
      base_filters: base_filters,
      data_filters: data_filters,
      count_filters: count_filters,
      count_with: count_with,
      map_fn: map_fn,
      map_count_fn: map_count_fn,
    }
  ) do
    base_q = apply(queries, :query, [query, base_filters])
    data_q = apply(queries, :filter, [base_q, data_filters])
    count_q = apply(queries, :filter, [base_q, count_filters])
    {:ok, [data, count]} = Repo.transact_many([{:all, data_q}, {count_with, count_q}])
    # IO.inspect(data: data, count: count)
    data = map_data(map_fn, data)
    count = map_count(map_count_fn, count)
    ret = Page.new(data, count, cursor_fn, page_opts)
    {:ok, ret}
  end

  defp map_data(nil, data), do: data
  defp map_data(fun, data) when is_function(fun, 1), do: Enum.map(data, fun)

  defp map_count(nil, data), do: data
  defp map_count(fun, data) when is_function(fun, 1), do: fun.(data)

end
