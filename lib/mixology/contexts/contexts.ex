# SPDX-License-Identifier: AGPL-3.0-only
defmodule CommonsPub.Common.Contexts do
  @doc "Helpers for writing contexts that deal with graphql"

  alias CommonsPub.GraphQL.{Page, Pages}
  alias CommonsPub.Repo

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
  # TODO: make them support no context or any context

  def context_feeds(obj) do
    # remove nils
    Enum.filter(context_feeds_list(obj), & &1)
  end

  defp context_feeds_list(%{context: %{character: %{inbox_id: inbox, outbox_id: outbox}}}),
    do: [inbox, outbox]

  defp context_feeds_list(%CommonsPub.Resources.Resource{} = r) do
    r = Repo.preload(r, collection: [:character, community: :character])

    [
      CommonsPub.Feeds.outbox_id(r.collection),
      CommonsPub.Feeds.outbox_id(Map.get(r.collection, :community))
    ]
  end

  defp context_feeds_list(%CommonsPub.Collections.Collection{} = c) do
    c = Repo.preload(c, [:character, community: :character])
    [CommonsPub.Feeds.outbox_id(c), CommonsPub.Feeds.outbox_id(Map.get(c, :community))]
  end

  defp context_feeds_list(%CommonsPub.Communities.Community{} = c) do
    c = Repo.preload(c, :character)
    [CommonsPub.Feeds.outbox_id(c)]
  end

  defp context_feeds_list(%CommonsPub.Users.User{} = u) do
    u = Repo.preload(u, :character)
    [CommonsPub.Feeds.outbox_id(u), CommonsPub.Feeds.inbox_id(u)]
  end

  defp context_feeds_list(%{inbox_id: inbox, outbox_id: outbox}), do: [inbox, outbox]

  defp context_feeds_list(%{character: %{inbox_id: inbox, outbox_id: outbox}}),
    do: [inbox, outbox]

  defp context_feeds_list(_), do: []
end
