defmodule CommonsPub.Tag.Categories do
  # import Ecto.Query
  alias Ecto.Changeset

  alias MoodleNet.{
    Common,
    # GraphQL,
    Repo,
    GraphQL.Page,
    Common.Contexts,
    Activities,
    Feeds
  }

  alias MoodleNet.Users.User
  alias MoodleNet.Feeds.FeedActivities
  alias MoodleNet.Workers.APPublishWorker

  alias CommonsPub.Tag.Category
  alias CommonsPub.Tag.Category.Queries

  alias CommonsPub.Character.Characters

  @facet_name "Category"

  def cursor(), do: &[&1.id]
  def test_cursor(), do: &[&1["id"]]

  def one(filters), do: Repo.single(Queries.query(Category, filters))
  def get(id), do: one([:default, id: id])

  def many(filters \\ []), do: {:ok, Repo.all(Queries.query(Category, filters))}
  def list(), do: many([:default])

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
  def create(creator, %{category: %{} = cat_attrs} = attrs) do
    create(
      creator,
      attrs
      |> Map.merge(cat_attrs)
      |> Map.delete(:category)
    )
  end

  def create(creator, %{facet: facet} = attrs)
      when not is_nil(facet) do
    Repo.transact_with(fn ->
      # TODO: check that the category doesn't already exist (same name and parent)

      with {:ok, category} <- insert_category(creator, attrs),
           {:ok, attrs} <- attrs_mixins_with_id(attrs, category),
           {:ok, taggable} <-
             CommonsPub.Tag.Taggables.maybe_make_taggable(creator, category, attrs),
           {:ok, profile} <- Profile.Profiles.create(creator, attrs),
           {:ok, character} <- Character.Characters.create(creator, attrs_with_username(attrs)) do
        category = %{category | taggable: taggable, character: character, profile: profile}
        act_attrs = %{verb: "created", is_local: is_nil(character.actor.peer_id)}
        {:ok, activity} = Activities.create(creator, category, act_attrs)
        Repo.preload(category, :caretaker)
        :ok = publish(creator, category.caretaker, character, activity)
        :ok = ap_publish("create", category)

        {:ok, category}
      end
    end)
  end

  def create(creator, attrs) do
    create(creator, Map.put(attrs, :facet, @facet_name))
  end

  defp attrs_mixins_with_id(attrs, category) do
    attrs = Map.put(attrs, :id, category.id)
    # IO.inspect(attrs)
    {:ok, attrs}
  end

  # todo: improve
  def attrs_with_username(%{preferred_username: preferred_username, name: name} = attrs)
      when is_nil(preferred_username) or preferred_username == "" do
    Map.put(attrs, :preferred_username, name <> "-" <> attrs.facet)
  end

  def attrs_with_username(
        %{preferred_username: preferred_username, profile: %{name: name}} = attrs
      )
      when is_nil(preferred_username) or preferred_username == "" do
    Map.put(attrs, :preferred_username, name <> "-" <> attrs.facet)
  end

  def attrs_with_username(%{name: name} = attrs) do
    Map.put(attrs, :preferred_username, name <> "-" <> attrs.facet)
  end

  def attrs_with_username(%{profile: %{name: name}} = attrs) do
    Map.put(attrs, :preferred_username, name <> "-" <> attrs.facet)
  end

  defp insert_category(user, attrs) do
    # IO.inspect(insert_category: attrs)
    cs = Category.create_changeset(user, attrs)
    with {:ok, category} <- Repo.insert(cs), do: {:ok, category}
  end

  def update(user, %Category{} = category, %{category: %{} = cat_attrs} = attrs) do
    update(
      user,
      category,
      attrs
      |> Map.merge(cat_attrs)
      |> Map.delete(:category)
    )
  end

  def update(user, %Category{} = category, attrs) do
    category = Repo.preload(category, [:profile, :character])

    IO.inspect(category)
    IO.inspect(attrs)

    Repo.transact_with(fn ->
      # :ok <- publish(category, :updated)
      with {:ok, category} <- Repo.update(Category.update_changeset(category, attrs)),
           {:ok, profile} <- Profile.Profiles.update(user, category.profile, attrs),
           {:ok, character} <- Characters.update(user, category.character, attrs) do
        {:ok, %{category | character: character, profile: profile}}
      end
    end)
  end

  # Feeds

  defp publish(%{outbox_id: creator_outbox}, %{outbox_id: caretaker_outbox}, category, activity) do
    feeds = [
      caretaker_outbox,
      creator_outbox,
      category.outbox_id,
      Feeds.instance_outbox_id()
    ]

    FeedActivities.publish(activity, feeds)
  end

  defp publish(%{outbox_id: creator_outbox}, _, category, activity) do
    feeds = [category.outbox_id, creator_outbox, Feeds.instance_outbox_id()]
    FeedActivities.publish(activity, feeds)
  end

  defp publish(_, _, category, activity) do
    feeds = [category.outbox_id, Feeds.instance_outbox_id()]
    FeedActivities.publish(activity, feeds)
  end

  defp ap_publish(verb, communities) when is_list(communities) do
    APPublishWorker.batch_enqueue(verb, communities)
    :ok
  end

  defp ap_publish(verb, %{actor: %{peer_id: nil}} = category) do
    APPublishWorker.enqueue(verb, %{"context_id" => category.id})
    :ok
  end

  defp ap_publish(_, _), do: :ok

  # TODO move this common module
  @doc "conditionally update a map"
  def maybe_put(map, _key, nil), do: map
  def maybe_put(map, key, value), do: Map.put(map, key, value)

  def soft_delete(%Category{} = c) do
    Repo.transact_with(fn ->
      with {:ok, c} <- Common.soft_delete(c) do
        {:ok, c}
      else
        e ->
          {:error, e}
      end
    end)
  end
end
