# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.GraphQL.PagesFlow do
  @enforce_keys [:queries, :query, :cursor_fn, :group_fn, :info, :page_opts]
  defstruct [
    :queries,
    :query,
    :cursor_fn,
    :group_fn,
    :info,
    :page_opts,
    base_filters: [],
    data_filters: [],
    count_filters: [],
    data_transform: nil,
    count_transform: nil,
  ]

  alias MoodleNet.Repo
  alias MoodleNet.GraphQL.{Page, Pages, PagesFlow}

  @type t :: %PagesFlow{
    queries: atom,
    query: atom,
    cursor_fn: (term -> term),
    group_fn: (term -> term),
    info: map,
    page_opts: map,
    base_filters: list,
    data_filters: list,
    count_filters: list,
    data_transform: ([term] -> [term]) | nil,
    count_transform: (term -> term) | nil,
  }

  def run(
    %PagesFlow{
      queries: queries,
      query: query,
      cursor_fn: cursor_fn,
      group_fn: group_fn,
      info: info,
      page_opts: page_opts,
      base_filters: base_filters,
      data_filters: data_filters,
      count_filters: count_filters,
      data_transform: data_transform,
      count_transform: count_transform,
    }
  ) do
    base_q = apply(queries, :query, [query, base_filters])
    data_q = apply(queries, :filter, [base_q, data_filters])
    count_q = apply(queries, :filter, [base_q, count_filters])
    {:ok, [data, counts]} = Repo.transact_many(all: data_q, all: count_q)
    data = transform(data_transform, data)
    counts = transform(count_transform, counts)
    {:ok, Pages.new(data, counts, cursor_fn, group_fn, page_opts)}
  end

  defp transform(nil, data), do: data
  defp transform(fun, data) when is_function(fun, 1), do: fun.(data)

end
