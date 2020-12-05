defmodule CommonsPub.GraphQL.Pagination do
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
      {:ok, CommonsPub.GraphQL.Page.new(data, counts, cursor_fn, page_opts)}
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
      {:ok, CommonsPub.GraphQL.Page.new(data, counts, cursor_fn, page_opts)}
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
      {:ok, CommonsPub.GraphQL.Pages.new(data, counts, cursor_fn, group_fn, page_opts)}
    end
  end

end
