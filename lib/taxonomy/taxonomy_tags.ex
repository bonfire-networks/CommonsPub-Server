defmodule Taxonomy.TaxonomyTags do
  # import Ecto.Query
  alias Ecto.Changeset

  alias MoodleNet.{
    # Common, GraphQL,
    GraphQL.Page,
    Common.Contexts,
    Repo
  }

  alias MoodleNet.Users.User
  alias Taxonomy.TaxonomyTag
  alias Taxonomy.TaxonomyTag.Queries

  # alias Character.Characters

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

  def page(cursor_fn, %{} = page_opts, base_filters, data_filters, count_filters) do
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
  def pages(
        cursor_fn,
        group_fn,
        page_opts,
        base_filters \\ [],
        data_filters \\ [],
        count_filters \\ []
      )

  def pages(cursor_fn, group_fn, page_opts, base_filters, data_filters, count_filters) do
    Contexts.pages(
      Queries,
      TaxonomyTag,
      cursor_fn,
      group_fn,
      page_opts,
      base_filters,
      data_filters,
      count_filters
    )
  end

  @doc "Takes an existing TaxonomyTag and makes it a Taggable, if one doesn't already exist"
  def maybe_make_taggable(%User{} = user, %TaxonomyTag{} = tag) do
    Repo.transact_with(fn ->
      tag = Repo.preload(tag, [:taggable, :parent_tag])

      # with Tag.Taggables.one(taxonomy_tag_id: tag.id) do
      with {:ok, taggable} <- Map.get(tag, :taggable) do
        # already exists
        taggable
      else
        _e -> make_taggable(user, tag)
      end
    end)
  end

  def maybe_make_taggable(%User{} = user, id) do
    with {:ok, tag} <- get(id) do
      make_taggable(user, tag)
    end
  end

  defp make_taggable(%User{} = user, %TaxonomyTag{parent_tag_id: parent_tag_id} = tag)
       when not is_nil(parent_tag_id) do
    tag = Repo.preload(tag, :parent_tag)
    parent_tag = tag.parent_tag

    IO.inspect(pointerise_parent: parent_tag)

    # pointerise the parent(s) first (recursively)
    {:ok, parent_taggable} = make_taggable(user, parent_tag)

    IO.inspect(parent_taggable: parent_taggable)

    create_tag =
      if(parent_taggable) do
        %{
          tag
          | parent_tag: parent_taggable,
            parent_tag_id: parent_taggable.id
        }
      else
        tag
      end

    # finally pointerise the child(ren), in hierarchical order
    create_taggable(user, create_tag)
  end

  defp make_taggable(%User{} = user, %TaxonomyTag{} = tag) do
    create_taggable(user, tag)
  end

  defp create_taggable(%User{} = user, tag) do
    IO.inspect(create_taggable: tag)

    tag = Repo.preload(tag, :taggable)
    tag = cleanup(tag)

    if(Ecto.assoc_loaded?(tag.taggable) and !is_nil(tag.taggable) and !is_nil(tag.taggable.id)) do
      # already has an associated taggable
      {:ok, tag.taggable}
    else
      IO.inspect(create_taggable: tag)

      Repo.transact_with(fn ->
        with {:ok, taggable} <- Tag.Taggables.create(user, tag) do
          {:ok, taggable}
        end
      end)
    end
  end

  @doc "Transform the generic fields of anything to be turned into a character."
  def cleanup(thing) do
    thing
    # convert to map
    |> Map.put(:taxonomy_tag, thing)
    |> Map.put(:taxonomy_tag_id, thing.id)
    |> Map.from_struct()
    |> Map.delete(:__meta__)
    # use Thing name as facet/trope
    |> Map.put(:facet, "Tag")
    |> Map.put(:prefix, "+")
    # avoid reusing IDs
    |> Map.delete(:id)
  end

  # TODO: take the user who is performing the update
  @spec update(User.t(), TaxonomyTag.t(), attrs :: map) ::
          {:ok, TaxonomyTag.t()} | {:error, Changeset.t()}
  def update(%User{} = _user, %TaxonomyTag{} = tag, attrs) do
    Repo.transact_with(fn ->
      #  {:ok, character} <- Character.update(user, tag.character, attrs)
      # :ok <- publish(tag, :updated)
      with {:ok, tag} <- Repo.update(TaxonomyTag.update_changeset(tag, attrs)) do
        {:ok, tag}
      end
    end)
  end

  # TODO move this common module
  @doc "conditionally update a map"
  def maybe_put(map, _key, nil), do: map
  def maybe_put(map, key, value), do: Map.put(map, key, value)
end
