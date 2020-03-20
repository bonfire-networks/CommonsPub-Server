defmodule MoodleNet.Features do
  alias MoodleNet.{Common, GraphQL, Repo}
  alias MoodleNet.Common.Contexts
  alias MoodleNet.Features.{Feature, Queries}
  alias MoodleNet.GraphQL.Fields
  alias MoodleNet.Meta.{Pointer, Pointers}
  alias MoodleNet.Users.User

  def one(filters), do: Repo.single(Queries.query(Feature, filters))

  def many(filters \\ []), do: {:ok, Repo.all(Queries.query(Feature, filters))}

  def fields(group_fn, filters \\ [])
  when is_function(group_fn, 1) do
    {:ok, fields} = many(filters)
    {:ok, Fields.new(fields, group_fn)}
  end

  @doc """
  Retrieves a Page of features according to various filters

  Used by:
  * GraphQL resolver bulk resolution
  """
  def page(cursor_fn, page_opts, base_filters \\ [], data_filters \\ [], count_filters \\ [])
  def page(cursor_fn, page_opts, base_filters, data_filters, count_filters) do
    Contexts.page Queries, Feature,
      cursor_fn, page_opts, base_filters, data_filters, count_filters
  end

  @doc """
  Retrieves a Pages of features according to various filters

  Used by:
  * GraphQL resolver bulk resolution
  """
  def pages(group_fn, cursor_fn, page_opts, base_filters \\ [], data_filters \\ [], count_filters \\ []) do
    Contexts.pages Queries, Feature,
      cursor_fn, group_fn, page_opts, base_filters, data_filters, count_filters
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
