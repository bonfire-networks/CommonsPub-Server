defmodule Taxonomy.Tags do
  import Ecto.Query
  alias Ecto.Changeset
  alias MoodleNet.{Common, GraphQL, Repo}
  alias MoodleNet.Batching.{Edges, EdgesPage, EdgesPages, NodesPage}
  # alias MoodleNet.Meta.{Pointer, Pointers, TableService}
  alias MoodleNet.Users.User
  alias Taxonomy.Tag
  alias Taxonomy.Tags.Queries
  alias Character.Characters

  def cursor(), do: &[&1.id]
  def test_cursor(), do: &[&1["id"]]

  def one(filters), do: Repo.single(Queries.query(Tag, filters))

  def many(filters \\ []), do: {:ok, Repo.all(Queries.query(Tag, filters))}

  @doc """
  Retrieves an Page of tags according to various filters

  Used by:
  * GraphQL resolver single-parent resolution
  """
  def page(cursor_fn, page_opts, base_filters \\ [], data_filters \\ [], count_filters \\ [])
  def page(cursor_fn, %{}=page_opts, base_filters, data_filters, count_filters) do
    base_q = Queries.query(Tag, base_filters)
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
    Contexts.pages Queries, Tag,
      cursor_fn, group_fn, page_opts, base_filters, data_filters, count_filters
  end

  @doc "Takes an existing Tag and creates a Character based on it"
  def characterise(%User{} = user, %Tag{} = tag) do
    characterise(user, tag, %{}) 
  end

  @spec characterise(User.t(), Tag.t(), attrs :: map) :: {:ok, Tag.t()} | {:error, Changeset.t()}
  def characterise(%User{} = user, %Tag{} = tag, attrs) do

    attrs = attrs 
    |> maybe_put(:name, tag.label)
    |> maybe_put(:summary, tag.description)
    |> Map.put(:facet, "Category")
    # |> maybe_put(:context, tag.parent_tag)

    # IO.inspect(tag)
    # IO.inspect(attrs)

    Repo.transact_with(fn ->
      with {:ok, character} <- Characters.create(user, attrs),
           {:ok, return} <- characterise(user, tag, character, attrs) 
            do
              {:ok, return }
      end
    end)
  end
  
  @doc "Takes an existing Tag and an existing Character and links them"
  @spec characterise(User.t(), Tag.t(), Character.t(), attrs :: map) :: {:ok, Tag.t()} | {:error, Changeset.t()}
  def characterise(%User{} = user, %Tag{} = tag, %Character{} = character, attrs) do
    Repo.transact_with(fn ->
      with {:ok, tag} <- Repo.update(Tag.update_changeset(tag, character, attrs))
            # :ok <- publish(tag, :updated) 
            do
              {:ok, %{ tag | character: character }}
      end
    end)
  end
  
  # TODO: take the user who is performing the update
  @spec update(User.t(), Tag.t(), attrs :: map) :: {:ok, Tag.t()} | {:error, Changeset.t()}
  def update(%User{} = user, %Tag{} = tag, attrs) do
    Repo.transact_with(fn ->
      with {:ok, tag} <- Repo.update(Tag.update_changeset(tag, attrs)),
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
