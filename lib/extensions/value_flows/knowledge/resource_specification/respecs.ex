# SPDX-License-Identifier: AGPL-3.0-only
defmodule ValueFlows.Knowledge.ResourceSpecification.ResourceSpecifications do
  alias MoodleNet.{Activities, Common, Feeds, Repo}
  alias MoodleNet.GraphQL.{Fields, Page}
  alias MoodleNet.Common.Contexts
  alias MoodleNet.Feeds.FeedActivities
  alias MoodleNet.Users.User
  alias MoodleNet.Meta.Pointers

  alias Geolocation.Geolocations
  # alias Measurement.Measure
  alias ValueFlows.Knowledge.ResourceSpecification
  alias ValueFlows.Knowledge.ResourceSpecification.Queries
  alias ValueFlows.Knowledge.Action
  alias ValueFlows.Knowledge.Action.Actions

  def cursor(), do: &[&1.id]
  def test_cursor(), do: &[&1["id"]]

  @doc """
  Retrieves a single one by arbitrary filters.
  Used by:
  * GraphQL Item queries
  * ActivityPub integration
  * Various parts of the codebase that need to query for collections (inc. tests)
  """
  def one(filters), do: Repo.single(Queries.query(ResourceSpecification, filters))

  @doc """
  Retrieves a list of them by arbitrary filters.
  Used by:
  * Various parts of the codebase that need to query for collections (inc. tests)
  """
  def many(filters \\ []), do: {:ok, Repo.all(Queries.query(ResourceSpecification, filters))}

  def fields(group_fn, filters \\ [])
      when is_function(group_fn, 1) do
    {:ok, fields} = many(filters)
    {:ok, Fields.new(fields, group_fn)}
  end

  @doc """
  Retrieves an Page of respecs according to various filters

  Used by:
  * GraphQL resolver single-parent resolution
  """
  def page(cursor_fn, page_opts, base_filters \\ [], data_filters \\ [], count_filters \\ [])

  def page(cursor_fn, %{} = page_opts, base_filters, data_filters, count_filters) do
    base_q = Queries.query(ResourceSpecification, base_filters)
    data_q = Queries.filter(base_q, data_filters)
    count_q = Queries.filter(base_q, count_filters)

    with {:ok, [data, counts]} <- Repo.transact_many(all: data_q, count: count_q) do
      {:ok, Page.new(data, counts, cursor_fn, page_opts)}
    end
  end

  @doc """
  Retrieves an Pages of respecs according to various filters

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
      ResourceSpecification,
      cursor_fn,
      group_fn,
      page_opts,
      base_filters,
      data_filters,
      count_filters
    )
  end

  ## mutations

  # @spec create(User.t(), Community.t(), attrs :: map) :: {:ok, ResourceSpecification.t()} | {:error, Changeset.t()}
  def create(%User{} = creator, %Action{} = state, %{id: _id} = context, attrs)
      when is_map(attrs) do
    do_create(creator, attrs, fn ->
      ResourceSpecification.create_changeset(creator, state, context, attrs)
    end)
  end

  # @spec create(User.t(), attrs :: map) :: {:ok, ResourceSpecification.t()} | {:error, Changeset.t()}
  def create(%User{} = creator, %Action{} = state, attrs) when is_map(attrs) do
    do_create(creator, attrs, fn ->
      ResourceSpecification.create_changeset(creator, state, attrs)
    end)
  end

  def do_create(creator, attrs, changeset_fn) do
    Repo.transact_with(fn ->
      cs = changeset_fn.()

      with {:ok, item} <- Repo.insert(cs),
           {:ok, item} <- ValueFlows.Util.try_tag_thing(creator, item, attrs),
           act_attrs = %{verb: "created", is_local: true},
           # FIXME
           {:ok, activity} <- Activities.create(creator, item, act_attrs),
           :ok <- publish(creator, item, activity, :created) do
        item = %{item | creator: creator}
        index(item)
        {:ok, item}
      end
    end)
  end

  defp publish(creator, respec, activity, :created) do
    feeds = [
      creator.outbox_id,
      Feeds.instance_outbox_id()
    ]

    with :ok <- FeedActivities.publish(activity, feeds) do
      ap_publish("create", respec.id, creator.id)
    end
  end

  defp publish(creator, context, respec, activity, :created) do
    feeds = [
      context.outbox_id,
      creator.outbox_id,
      Feeds.instance_outbox_id()
    ]

    with :ok <- FeedActivities.publish(activity, feeds) do
      ap_publish("create", respec.id, creator.id)
    end
  end

  defp publish(respec, :updated) do
    # TODO: wrong if edited by admin
    ap_publish("update", respec.id, respec.creator_id)
  end

  defp publish(respec, :deleted) do
    # TODO: wrong if edited by admin
    ap_publish("delete", respec.id, respec.creator_id)
  end

  # FIXME
  defp ap_publish(verb, context_id, user_id) do
    MoodleNet.Workers.APPublishWorker.enqueue(verb, %{
      "context_id" => context_id,
      "user_id" => user_id
    })

    :ok
  end

  defp ap_publish(_, _, _), do: :ok

  # TODO: take the user who is performing the update
  # @spec update(%ResourceSpecification{}, attrs :: map) :: {:ok, ResourceSpecification.t()} | {:error, Changeset.t()}
  def update(%ResourceSpecification{} = respec, attrs) do
    do_update(respec, attrs, &ResourceSpecification.update_changeset(&1, attrs))
  end

  def update(%ResourceSpecification{} = respec, %{id: _id} = context, attrs) do
    do_update(respec, attrs, &ResourceSpecification.update_changeset(&1, context, attrs))
  end

  def do_update(respec, attrs, changeset_fn) do
    Repo.transact_with(fn ->
      respec =
        Repo.preload(respec, [
          :default_unit_of_effort
        ])

      cs =
        respec
        |> changeset_fn.()

      with {:ok, respec} <- Repo.update(cs),
           {:ok, respec} <- ValueFlows.Util.try_tag_thing(nil, respec, attrs),
           :ok <- publish(respec, :updated) do
        {:ok, respec}
      end
    end)
  end

  def soft_delete(%ResourceSpecification{} = respec) do
    Repo.transact_with(fn ->
      with {:ok, respec} <- Common.soft_delete(respec),
           :ok <- publish(respec, :deleted) do
        {:ok, respec}
      end
    end)
  end

  def indexing_object_format(obj) do
    # icon = MoodleNet.Uploads.remote_url_from_id(obj.icon_id)
    image = MoodleNet.Uploads.remote_url_from_id(obj.image_id)

    %{
      "index_type" => "ResourceSpecification",
      "id" => obj.id,
      # "canonicalUrl" => obj.actor.canonical_url,
      # "icon" => icon,
      "image" => image,
      "name" => obj.name,
      "summary" => Map.get(obj, :note),
      "published_at" => obj.published_at,
      "creator" => CommonsPub.Search.Indexer.format_creator(obj)
      # "index_instance" => URI.parse(obj.actor.canonical_url).host, # home instance of object
    }
  end

  defp index(obj) do
    object = indexing_object_format(obj)

    CommonsPub.Search.Indexer.index_object(object)

    :ok
  end
end
