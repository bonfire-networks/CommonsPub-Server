# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Common.Contexts do
  @doc "Helpers for writing contexts that deal with graphql"

  alias MoodleNet.GraphQL.{Page, Pages}
  alias MoodleNet.Repo

  def page(
    queries,
    schema,
    cursor_fn,
    %{} = page_opts,
    base_filters,
    data_filters,
    count_filters
  )
  when is_atom(queries)
  and is_atom(schema)
  and is_function(cursor_fn, 1)
  and is_list(base_filters)
  and is_list(data_filters)
  and is_list(count_filters) do
    queries_args = [schema,page_opts, base_filters, data_filters, count_filters]
    {data_q, count_q} = apply(queries, :queries, queries_args)
    with {:ok, [data, counts]} <- Repo.transact_many(all: data_q, count: count_q) do
      {:ok, Page.new(data, counts, cursor_fn, page_opts)}
    end
  end

  def page_all(
    queries,
    schema,
    cursor_fn,
    %{} = page_opts,
    base_filters,
    data_filters,
    count_filters
  )
  when is_atom(queries)
  and is_atom(schema)
  and is_function(cursor_fn, 1)
  and is_list(base_filters)
  and is_list(data_filters)
  and is_list(count_filters) do
    queries_args = [schema,page_opts, base_filters, data_filters, count_filters]
    {data_q, count_q} = apply(queries, :queries, queries_args)
    with {:ok, [data, counts]} <- Repo.transact_many(all: data_q, all: count_q) do
      {:ok, Page.new(data, counts, cursor_fn, page_opts)}
    end
  end

  def pages(
    queries,
    schema,
    cursor_fn,
    group_fn,
    page_opts,
    base_filters,
    data_filters,
    count_filters
  )
  when is_atom(queries)
  and is_atom(schema)
  and is_function(cursor_fn, 1)
  and is_function(group_fn, 1)
  and is_list(base_filters)
  and is_list(data_filters)
  and is_list(count_filters) do
    queries_args = [schema,page_opts, base_filters, data_filters, count_filters]
    {data_q, count_q} = apply(queries, :queries, queries_args)
    with {:ok, [data, counts]} <- Repo.transact_many(all: data_q, all: count_q) do
      {:ok, Pages.new(data, counts, cursor_fn, group_fn, page_opts)}
    end
  end

end
