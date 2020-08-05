defmodule CommonsPub.Tag.Categories do
  # import Ecto.Query
  alias Ecto.Changeset

  alias MoodleNet.{
    # Common,
    # GraphQL,
    Repo,
    GraphQL.Page,
    Common.Contexts
  }

  alias MoodleNet.Users.User
  alias CommonsPub.Tag.Category
  alias CommonsPub.Tag.Category.Queries

  alias Character.Characters

  @facet_name "Category"

  def cursor(), do: &[&1.id]
  def test_cursor(), do: &[&1["id"]]

  def one(filters), do: Repo.single(Queries.query(Category, filters))
  def get(id), do: one(id: id, preload: :parent_category, preload: :profile, preload: :character)

  def many(filters \\ []), do: {:ok, Repo.all(Queries.query(Category, filters))}

  @doc """
  Retrieves an Page of categorys according to various filters

  Used by:
  * GraphQL resolver single-parent resolution
  """
  def page(cursor_fn, page_opts, base_filters \\ [], data_filters \\ [], count_filters \\ [])

  def page(cursor_fn, %{} = page_opts, base_filters, data_filters, count_filters) do
    base_q = Queries.query(Category, base_filters)
    data_q = Queries.filter(base_q, data_filters)
    count_q = Queries.filter(base_q, count_filters)

    with {:ok, [data, counts]} <- Repo.transact_many(all: data_q, count: count_q) do
      {:ok, Page.new(data, counts, cursor_fn, page_opts)}
    end
  end

  @doc """
  Retrieves an Pages of categorys according to various filters

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
      Category,
      cursor_fn,
      group_fn,
      page_opts,
      base_filters,
      data_filters,
      count_filters
    )
  end

  ## mutations

  @doc """
  Create a brand-new category object, with info stored in Profile and Character mixins
  """
  def create(%User{} = creator, %{facet: facet} = attrs) when not is_nil(facet) do
    Repo.transact_with(fn ->
      # TODO: check that the category doesn't already exist (same name and parent)

      with {:ok, category} <- insert_category(attrs),
           {:ok, attrs} <- attrs_mixins_with_id(attrs, category),
           {:ok, taggable} <-
             CommonsPub.Tag.Taggables.maybe_make_taggable(creator, category, attrs),
           {:ok, profile} <- Profile.Profiles.create(creator, attrs),
           {:ok, character} <- Character.Characters.create(creator, attrs) do
        {:ok, %{category | taggable: taggable, character: character, profile: profile}}
      end
    end)
  end

  def create(%User{} = creator, attrs) do
    create(creator, Map.put(attrs, :facet, @facet_name))
  end

  defp attrs_mixins_with_id(attrs, category) do
    attrs = Map.put(attrs, :id, category.id)
    # IO.inspect(attrs)
    {:ok, attrs}
  end

  defp insert_category(attrs) do
    # IO.inspect(insert_category: attrs)
    cs = Category.create_changeset(attrs)
    with {:ok, category} <- Repo.insert(cs), do: {:ok, category}
  end

  # TODO: take the user who is performing the update
  @spec update(User.t(), Category.t(), attrs :: map) ::
          {:ok, Category.t()} | {:error, Changeset.t()}
  def update(%User{} = user, %Category{} = category, attrs) do
    Repo.transact_with(fn ->
      # :ok <- publish(category, :updated)
      with {:ok, category} <- Repo.update(Category.update_changeset(category, attrs)),
           {:ok, profile} <- Profile.Profiles.update(user, category.profile, attrs),
           {:ok, character} <- Characters.update(user, category.character, attrs) do
        {:ok, %{category | character: character}}
      end
    end)
  end

  # TODO move this common module
  @doc "conditionally update a map"
  def maybe_put(map, _key, nil), do: map
  def maybe_put(map, key, value), do: Map.put(map, key, value)
end
