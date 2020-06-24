defmodule Tag.Taggables do
  import Ecto.Query
  alias Ecto.Changeset
  alias MoodleNet.{Common, GraphQL, Repo}
  alias MoodleNet.Batching.{Edges, EdgesPage, EdgesPages, NodesPage}
  # alias MoodleNet.Meta.{Pointer, Pointers, TableService}
  alias MoodleNet.Users.User
  alias Tag.Taggable
  alias Tag.Taggable.Queries
  alias Character.Characters

  def cursor(), do: &[&1.id]
  def test_cursor(), do: &[&1["id"]]

  def one(filters), do: Repo.single(Queries.query(Taggable, filters))

  def many(filters \\ []), do: {:ok, Repo.all(Queries.query(Taggable, filters))}

  @doc """
  Retrieves an Page of tags according to various filters

  Used by:
  * GraphQL resolver single-parent resolution
  """
  def page(cursor_fn, page_opts, base_filters \\ [], data_filters \\ [], count_filters \\ [])
  def page(cursor_fn, %{}=page_opts, base_filters, data_filters, count_filters) do
    base_q = Queries.query(Taggable, base_filters)
    data_q = Queries.filter(base_q, data_filters)
    count_q = Queries.filter(base_q, count_filters)
    with {:ok, [data, counts]} <- Repo.transact_many(all: data_q, count: count_q) do
      {:ok, Page.new(data, counts, cursor_fn, page_opts)}
    end
  end

  @doc """
  Retrieves an Pages of tags according to various filters

  Used by:
  * GraphQL resolver bulk resolution
  """
  def pages(cursor_fn, group_fn, page_opts, base_filters \\ [], data_filters \\ [], count_filters \\ [])
  def pages(cursor_fn, group_fn, page_opts, base_filters, data_filters, count_filters) do
    Contexts.pages Queries, Taggable,
      cursor_fn, group_fn, page_opts, base_filters, data_filters, count_filters
  end


  # TODO: take the user who is performing the update
  @spec update(User.t(), Taggable.t(), attrs :: map) :: {:ok, Taggable.t()} | {:error, Changeset.t()}
  def update(%User{} = user, %Taggable{} = tag, attrs) do
    Repo.transact_with(fn ->
      with {:ok, tag} <- Repo.update(Taggable.update_changeset(tag, attrs)),
           {:ok, character} <- Character.update(user, tag.character, attrs)
            # :ok <- publish(tag, :updated) 
            do
              {:ok, %{ tag | character: character }}
      end
    end)
  end

  @ doc "conditionally update a map" #TODO move this common module
  def maybe_put(map, _key, nil), do: map
  def maybe_put(map, key, value), do: Map.put(map, key, value)
  
end
