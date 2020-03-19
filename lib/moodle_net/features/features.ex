defmodule MoodleNet.Features do
  import Ecto.Query
  alias Ecto.Changeset
  alias MoodleNet.{Common, GraphQL, Repo}
  alias MoodleNet.Batching.{Edges, EdgesPage, EdgesPages, NodesPage}
  alias MoodleNet.Features.{Feature, Queries}
  alias MoodleNet.Meta.{Pointer, Pointers, TableService}
  alias MoodleNet.Users.User

  def one(filters), do: Repo.single(Queries.query(Feature, filters))

  def many(filters \\ []), do: {:ok, Repo.all(Queries.query(Feature, filters))}

  def nodes_page(cursor_fn, base_filters \\ [], data_filters \\ [], count_filters \\ [])
  when is_function(cursor_fn, 1) do
    {data_q, count_q} = Queries.queries(Feature, base_filters, data_filters, count_filters)
    with {:ok, [data, count]} <- Repo.transact_many(all: data_q, count: count_q) do
      {:ok, NodesPage.new(data, count, cursor_fn)}
    end
  end

  def edges(group_fn, filters \\ [])
  when is_function(group_fn, 1) do
    {:ok, edges} = many(filters)
    {:ok, Edges.new(edges, group_fn)}
  end

  @doc """
  Retrieves an EdgesPages of feed activities according to various filters

  Used by:
  * GraphQL resolver bulk resolution
  """
  def edges_page(cursor_fn, base_filters \\ [], data_filters \\ [], count_filters \\ [])
  def edges_page(cursor_fn, base_filters, data_filters, count_filters)
  when is_function(cursor_fn, 1) do
    {data_q, count_q} = Queries.queries(Feature, base_filters, data_filters, count_filters)
    with {:ok, [data, count]} <- Repo.transact_many(all: data_q, count: count_q) do
      {:ok, EdgesPage.new(data, count, cursor_fn)}
    end
  end

  def edges_pages(group_fn, cursor_fn, base_filters \\ [], data_filters \\ [], count_filters \\ [])
  when is_function(group_fn, 1) and is_function(cursor_fn, 1) do
    {data_q, count_q} = Queries.queries(Feature, base_filters, data_filters, count_filters)
    with {:ok, [data, count]} <- Repo.transact_many(all: data_q, all: count_q) do
      {:ok, EdgesPages.new(data, count, group_fn, cursor_fn)}
    end
  end

  def create(%User{}=creator, %Pointer{}=context, attrs) do
    target_table = Pointers.table!(context)
    if target_table.schema in get_valid_contexts() do
      Repo.insert(Feature.create_changeset(creator, context, attrs))
    else
      {:error, GraphQL.not_permitted()}
    end
  end
  def create(%User{}=creator, %{__struct__: struct}=context, attrs) do
    if struct in get_valid_contexts() do
      Repo.insert(Feature.create_changeset(creator, context, attrs))
    else
      {:error, GraphQL.not_permitted()}
    end
  end

  defp get_valid_contexts() do
    Application.fetch_env!(:moodle_net, __MODULE__)
    |> Keyword.fetch!(:valid_contexts)
  end

  def soft_delete(%Feature{} = feature), do: Common.soft_delete(feature)
end
