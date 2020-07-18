defmodule Tag.Taggables do
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
  alias Tag.Taggable
  alias Tag.Taggable.Queries

  alias Character.Characters

  @facet_name "Tag"

  def cursor(), do: &[&1.id]
  def test_cursor(), do: &[&1["id"]]

  def one(filters), do: Repo.single(Queries.query(Taggable, filters))
  def get(id), do: one(id: id, preload: :parent_tag, preload: :profile, preload: :character)

  def many(filters \\ []), do: {:ok, Repo.all(Queries.query(Taggable, filters))}

  @doc """
  Retrieves an Page of tags according to various filters

  Used by:
  * GraphQL resolver single-parent resolution
  """
  def page(cursor_fn, page_opts, base_filters \\ [], data_filters \\ [], count_filters \\ [])

  def page(cursor_fn, %{} = page_opts, base_filters, data_filters, count_filters) do
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
      Taggable,
      cursor_fn,
      group_fn,
      page_opts,
      base_filters,
      data_filters,
      count_filters
    )
  end

  ## mutations

  @spec create(User.t(), attrs :: map) :: {:ok, Taggable.t()} | {:error, Changeset.t()}
  def create(%User{} = creator, attrs) when is_map(attrs) do
    Repo.transact_with(fn ->
      attrs = Map.put(attrs, :facet, @facet_name)

      # TODO: check that the tag doesn't already exist (same name and parent)

      with {:ok, taggable} <- insert_taggable(attrs),
           {:ok, attrs} <- attrs_with_taggable(attrs, taggable),
           {:ok, profile} <- Profile.Profiles.create(creator, attrs),
           {:ok, character} <- Character.Characters.create(creator, attrs) do
        {:ok, %{taggable | character: character, profile: profile}}
      end
    end)
  end

  defp attrs_with_taggable(attrs, taggable) do
    attrs = Map.put(attrs, :id, taggable.id)
    # IO.inspect(attrs)
    {:ok, attrs}
  end

  defp insert_taggable(attrs) do
    # IO.inspect(insert_taggable: attrs)
    cs = Taggable.create_changeset(attrs)
    with {:ok, taggable} <- Repo.insert(cs), do: {:ok, taggable}
  end

  # TODO: take the user who is performing the update
  @spec update(User.t(), Taggable.t(), attrs :: map) ::
          {:ok, Taggable.t()} | {:error, Changeset.t()}
  def update(%User{} = user, %Taggable{} = tag, attrs) do
    Repo.transact_with(fn ->
      # :ok <- publish(tag, :updated)
      with {:ok, tag} <- Repo.update(Taggable.update_changeset(tag, attrs)),
           {:ok, character} <- Characters.update(user, tag.character, attrs) do
        {:ok, %{tag | character: character}}
      end
    end)
  end

  # TODO move this common module
  @doc "conditionally update a map"
  def maybe_put(map, _key, nil), do: map
  def maybe_put(map, key, value), do: Map.put(map, key, value)
end
