defmodule MoodleNet.Features do
  import Ecto.Query
  alias Ecto.Changeset
  alias MoodleNet.{Collections, Common, Communities, GraphQL, Repo}
  alias MoodleNet.Batching.{Edges, EdgesPage, EdgesPages, NodesPage}
  alias MoodleNet.Features.{Feature, Queries}
  alias MoodleNet.Collections.Collection
  alias MoodleNet.Communities.Community
  alias MoodleNet.Meta.TableService
  alias MoodleNet.Users.User

  def one(filters), do: Repo.single(Queries.query(Feature, filters))

  def many(filters \\ []), do: Repo.all(Queries.query(Feature, filters))

  def create(%User{}=creator, context, attrs) do
    Repo.insert(Feature.create_changeset(creator, context, attrs))
  end

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

end
