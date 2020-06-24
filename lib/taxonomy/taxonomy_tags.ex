defmodule Taxonomy.TaxonomyTags do
  import Ecto.Query
  alias Ecto.Changeset
  alias MoodleNet.{Common, GraphQL, Repo}
  alias MoodleNet.Batching.{Edges, EdgesPage, EdgesPages, NodesPage}
  # alias MoodleNet.Meta.{Pointer, Pointers, TableService}
  alias MoodleNet.Users.User
  alias Taxonomy.TaxonomyTag
  alias Taxonomy.TaxonomyTag.Queries
  alias Character.Characters

  def cursor(), do: &[&1.id]
  def test_cursor(), do: &[&1["id"]]

  def one(filters), do: Repo.single(Queries.query(TaxonomyTag, filters))

  def get(id), do: one(id: id, preload: :parent_tag, preload: :taggable) 

  def many(filters \\ []), do: {:ok, Repo.all(Queries.query(TaxonomyTag, filters))}

  @doc """
  Retrieves an Page of tags according to various filters

  Used by:
  * GraphQL resolver single-parent resolution
  """
  def page(cursor_fn, page_opts, base_filters \\ [], data_filters \\ [], count_filters \\ [])
  def page(cursor_fn, %{}=page_opts, base_filters, data_filters, count_filters) do
    base_q = Queries.query(TaxonomyTag, base_filters)
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
    Contexts.pages Queries, TaxonomyTag,
      cursor_fn, group_fn, page_opts, base_filters, data_filters, count_filters
  end

  @doc "Takes an existing TaxonomyTag and makes it a Taggable"
  def make_taggable(%User{} = user, %TaxonomyTag{} = tag) do

    Repo.transact_with(fn ->
      with {:ok, tag} <- pointerise(user, tag) # add a Pointer ID 
            do
              {:ok, tag }
      end
    end)
  end

  
  @doc "Takes an existing TaxonomyTag and adds a Pointer ID"
  def pointerise(%User{} = user, %TaxonomyTag{parent_tag_id: parent_tag_id} = tag) do

    if(!is_nil(parent_tag_id)) do # there is a parent

      {:ok, parent_tag} = if(!Ecto.assoc_loaded?(tag.parent_tag)) do # parent is not loaded
        get(tag.parent_tag_id)
      else
        {:ok, tag.parent_tag}
      end

      IO.inspect(pointerise_parent: parent_tag)
      parent_pointer = pointerise(user, parent_tag)

      # tag[:parent_tag] = parent_pointer
      # tag[:parent_tag_id] = parent_pointer.id

      create_tag = %{tag | parent_tag: parent_pointer, parent_tag_id: parent_pointer.id}
  
      pointerise_tag(user, create_tag)

    else

      pointerise_tag(user, tag)

    end

  end

  def pointerise(%User{} = user, %TaxonomyTag{} = tag) do
    pointerise_tag(user, tag)
  end

  def pointerise_tag(%User{} = user, %TaxonomyTag{} = tag) do

    IO.inspect(pointerise: tag)

    if(!is_nil(tag.taggable)) do # already has one
      {:ok, tag.taggable }
    else

      ctag = cleanup(tag)

      IO.inspect(ctag: ctag)

      Repo.transact_with(fn ->

        with {:ok, taggable} <- Tag.Taggables.create(user, ctag)
              do
                {:ok, taggable }
        end
      end)

    end
  end

    @doc "Transform the generic fields of anything to be turned into a character."
    def cleanup(thing) do
      thing 
      |> Map.put(:facet, "Tag") # use Thing name as Character facet/trope
      |> Map.delete(:id) # avoid reusing IDs
      |> Map.from_struct |> Map.delete(:__meta__) # convert to map
    end 
  
  
  # TODO: take the user who is performing the update
  @spec update(User.t(), TaxonomyTag.t(), attrs :: map) :: {:ok, TaxonomyTag.t()} | {:error, Changeset.t()}
  def update(%User{} = user, %TaxonomyTag{} = tag, attrs) do
    Repo.transact_with(fn ->
      with {:ok, tag} <- Repo.update(TaxonomyTag.update_changeset(tag, attrs))
          #  {:ok, character} <- Character.update(user, tag.character, attrs)
            # :ok <- publish(tag, :updated) 
            do
              {:ok, tag }
      end
    end)
  end

  @ doc "conditionally update a map" #TODO move this common module
  def maybe_put(map, _key, nil), do: map
  def maybe_put(map, key, value), do: Map.put(map, key, value)
  
end
