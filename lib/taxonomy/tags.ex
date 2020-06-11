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
  def tag_characterise(%User{} = user, %Tag{} = tag) do

    Repo.transact_with(fn ->
      with {:ok, tag} <- pointerise(tag), # add a Pointer ID 
           {:ok, return} <- Character.Characters.characterise(user, tag) 
            do
              {:ok, return }
      end
    end)
  end

  def characterisation(attrs) do

    # IO.inspect(attrs.label)
    attrs 
    |> Map.put(:name, attrs.label)
    |> Map.put(:summary, attrs.description)
    # |> maybe_put(:context, tag.parent_tag)

  end
  
  @doc "Takes an existing Tag and adds a Pointer ID"
  def pointerise(%Tag{} = tag) do

    if(!is_nil(tag.pointer_id)) do # already has one
      {:ok, tag }
    else

      pointer_id = Ecto.ULID.generate()

      Repo.transact_with(fn ->

        with {:ok, tag} <- Repo.update(Tag.update_changeset(tag, %{ pointer_id: pointer_id}))
              do
                {:ok, tag }
        end
      end)

    end
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
