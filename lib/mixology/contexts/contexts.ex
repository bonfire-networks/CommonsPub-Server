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
      when is_atom(queries) and
             is_atom(schema) and
             is_function(cursor_fn, 1) and
             is_list(base_filters) and
             is_list(data_filters) and
             is_list(count_filters) do
    # queries_args = [schema, page_opts, base_filters, data_filters, count_filters]
    base_q = apply(queries, :query, [schema, base_filters])
    data_q = apply(queries, :filter, [base_q, data_filters])
    count_q = apply(queries, :filter, [base_q, count_filters])

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
      when is_atom(queries) and
             is_atom(schema) and
             is_function(cursor_fn, 1) and
             is_list(base_filters) and
             is_list(data_filters) and
             is_list(count_filters) do
    queries_args = [schema, page_opts, base_filters, data_filters, count_filters]
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
      when is_atom(queries) and
             is_atom(schema) and
             is_function(cursor_fn, 1) and
             is_function(group_fn, 1) and
             is_list(base_filters) and
             is_list(data_filters) and
             is_list(count_filters) do
    queries_args = [schema, page_opts, base_filters, data_filters, count_filters]
    {data_q, count_q} = apply(queries, :queries, queries_args)

    with {:ok, [data, counts]} <- Repo.transact_many(all: data_q, all: count_q) do
      {:ok, Pages.new(data, counts, cursor_fn, group_fn, page_opts)}
    end
  end

  # FIXME: make these config-driven and generic:

  def context_feeds(%MoodleNet.Resources.Resource{} = resource) do
    r = Repo.preload(resource, collection: [:community])
    [r.collection.outbox_id, r.collection.community.outbox_id]
  end

  def context_feeds(%MoodleNet.Collections.Collection{} = collection) do
    c = Repo.preload(collection, [:community])
    [c.outbox_id, c.community.outbox_id]
  end

  def context_feeds(%MoodleNet.Communities.Community{outbox_id: id}), do: [id]

  def context_feeds(%MoodleNet.Users.User{inbox_id: inbox, outbox_id: outbox}),
    do: [inbox, outbox]

  def context_feeds(_), do: []
end
