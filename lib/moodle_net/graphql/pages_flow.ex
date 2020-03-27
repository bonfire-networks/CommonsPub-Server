# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.GraphQL.PagesFlow do
  @enforce_keys [:queries, :query, :cursor_fn, :group_fn, :page_opts]
  defstruct [
    :queries,
    :query,
    :cursor_fn,
    :group_fn,
    :page_opts,
    base_filters: [],
    data_filters: [],
    count_filters: [],
    map_fn: nil,
    map_counts_fn: nil,
  ]

  alias MoodleNet.Repo
  alias MoodleNet.GraphQL.{Page, Pages, PagesFlow}

  @type t :: %PagesFlow{
    queries: atom,
    query: atom,
    cursor_fn: (term -> term),
    group_fn: (term -> term),
    page_opts: map,
    base_filters: list,
    data_filters: list,
    count_filters: list,
    map_fn: (term -> term) | nil,
    map_counts_fn: (term -> term) | nil,
  }

  def run(
    %PagesFlow{
      queries: queries,
      query: query,
      cursor_fn: cursor_fn,
      group_fn: group_fn,
      page_opts: page_opts,
      base_filters: base_filters,
      data_filters: data_filters,
      count_filters: count_filters,
      map_fn: map_fn,
      map_counts_fn: map_counts_fn,
    }
  ) do
    base_q = apply(queries, :query, [query, base_filters])
    data_q = apply(queries, :filter, [base_q, data_filters])
    count_q = apply(queries, :filter, [base_q, count_filters])
    {:ok, [data, counts]} = Repo.transact_many(all: data_q, all: count_q)
    data = group_data(data, group_fn, map_fn)
    counts = group_counts(counts, map_counts_fn)
    Pages.new(data, counts, cursor_fn, page_opts)
  end

  defp group_data(data, group_fn, nil), do: Enum.group_by(data, group_fn)
  defp group_data(data, group_fn, map_fn), do: Enum.group_by(data, group_fn, map_fn)

  defp group_counts(counts, nil), do: Map.new(counts)
  defp group_counts(counts, map_fn), do: Map.new(counts, map_fn)

end
