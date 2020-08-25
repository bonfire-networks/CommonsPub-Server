# SPDX-License-Identifier: AGPL-3.0-only
defmodule ValueFlows.Observation.EconomicResource.EconomicResources do
  alias MoodleNet.{Activities, Common, Feeds, Repo}
  alias MoodleNet.GraphQL.{Fields, Page}
  alias MoodleNet.Common.Contexts
  alias MoodleNet.Feeds.FeedActivities
  alias MoodleNet.Users.User
  alias MoodleNet.Meta.Pointers

  alias Geolocation.Geolocations
  # alias Measurement.Measure
  alias ValueFlows.Observation.EconomicResource
  alias ValueFlows.Observation.EconomicResource.Queries
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
  def one(filters), do: Repo.single(Queries.query(EconomicResource, filters))

  @doc """
  Retrieves a list of them by arbitrary filters.
  Used by:
  * Various parts of the codebase that need to query for collections (inc. tests)
  """
  def many(filters \\ []), do: {:ok, Repo.all(Queries.query(EconomicResource, filters))}

  def fields(group_fn, filters \\ [])
      when is_function(group_fn, 1) do
    {:ok, fields} = many(filters)
    {:ok, Fields.new(fields, group_fn)}
  end

  @doc """
  Retrieves an Page of resources according to various filters

  Used by:
  * GraphQL resolver single-parent resolution
  """
  def page(cursor_fn, page_opts, base_filters \\ [], data_filters \\ [], count_filters \\ [])

  def page(cursor_fn, %{} = page_opts, base_filters, data_filters, count_filters) do
    base_q = Queries.query(EconomicResource, base_filters)
    data_q = Queries.filter(base_q, data_filters)
    count_q = Queries.filter(base_q, count_filters)

    with {:ok, [data, counts]} <- Repo.transact_many(all: data_q, count: count_q) do
      {:ok, Page.new(data, counts, cursor_fn, page_opts)}
    end
  end

  @doc """
  Retrieves an Pages of resources according to various filters

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
      EconomicResource,
      cursor_fn,
      group_fn,
      page_opts,
      base_filters,
      data_filters,
      count_filters
    )
  end

  ## mutations

  # @spec create(User.t(), Community.t(), attrs :: map) :: {:ok, EconomicResource.t()} | {:error, Changeset.t()}
  def create(%User{} = creator, %Action{} = state, %{id: _id} = context, attrs)
      when is_map(attrs) do
    do_create(creator, attrs, fn ->
      EconomicResource.create_changeset(creator, state, context, attrs)
    end)
  end

  # @spec create(User.t(), attrs :: map) :: {:ok, EconomicResource.t()} | {:error, Changeset.t()}
  def create(%User{} = creator, %Action{} = state, attrs) when is_map(attrs) do
    do_create(creator, attrs, fn ->
      EconomicResource.create_changeset(creator, state, attrs)
    end)
  end

  def do_create(creator, attrs, changeset_fn) do
    attrs = parse_measurement_attrs(attrs)

    Repo.transact_with(fn ->
      cs =
        changeset_fn.()
        |> EconomicResource.change_measures(attrs)

      with {:ok, cs} <- change_current_location(cs, attrs),
           {:ok, cs} <- change_agent(cs, attrs),
           {:ok, item} <- Repo.insert(cs),
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

  defp publish(creator, resource, activity, :created) do
    feeds = [
      creator.outbox_id,
      Feeds.instance_outbox_id()
    ]

    with :ok <- FeedActivities.publish(activity, feeds) do
      ap_publish("create", resource.id, creator.id)
    end
  end

  defp publish(creator, context, resource, activity, :created) do
    feeds = [
      context.outbox_id,
      creator.outbox_id,
      Feeds.instance_outbox_id()
    ]

    with :ok <- FeedActivities.publish(activity, feeds) do
      ap_publish("create", resource.id, creator.id)
    end
  end

  defp publish(resource, :updated) do
    # TODO: wrong if edited by admin
    ap_publish("update", resource.id, resource.creator_id)
  end

  defp publish(resource, :deleted) do
    # TODO: wrong if edited by admin
    ap_publish("delete", resource.id, resource.creator_id)
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
  # @spec update(%EconomicResource{}, attrs :: map) :: {:ok, EconomicResource.t()} | {:error, Changeset.t()}
  def update(%EconomicResource{} = resource, attrs) do
    do_update(resource, attrs, &EconomicResource.update_changeset(&1, attrs))
  end

  def update(%EconomicResource{} = resource, %{id: _id} = context, attrs) do
    do_update(resource, attrs, &EconomicResource.update_changeset(&1, context, attrs))
  end

  def do_update(resource, attrs, changeset_fn) do
    attrs = parse_measurement_attrs(attrs)

    Repo.transact_with(fn ->
      resource =
        Repo.preload(resource, [
          :accounting_quantity,
          :onhand_quantity,
          :effort_quantity,
          :current_location
        ])

      cs =
        resource
        |> changeset_fn.()
        |> EconomicResource.change_measures(attrs)

      with {:ok, cs} <- change_current_location(cs, attrs),
           {:ok, cs} <- change_agent(cs, attrs),
           {:ok, cs} <- change_action(cs, attrs),
           {:ok, resource} <- Repo.update(cs),
           {:ok, resource} <- ValueFlows.Util.try_tag_thing(nil, resource, attrs),
           :ok <- publish(resource, :updated) do
        {:ok, resource}
      end
    end)
  end

  def soft_delete(%EconomicResource{} = resource) do
    Repo.transact_with(fn ->
      with {:ok, resource} <- Common.soft_delete(resource),
           :ok <- publish(resource, :deleted) do
        {:ok, resource}
      end
    end)
  end

  def indexing_object_format(obj) do
    # icon = MoodleNet.Uploads.remote_url_from_id(obj.icon_id)
    image = MoodleNet.Uploads.remote_url_from_id(obj.image_id)

    %{
      "index_type" => "EconomicResource",
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

  defp change_agent(changeset, attrs) do
    with {:ok, changeset} <- change_primary_accountable(changeset, attrs) do
      change_receiver(changeset, attrs)
    end
  end

  defp change_primary_accountable(changeset, %{primary_accountable: primary_accountable_id}) do
    with {:ok, pointer} <- Pointers.one(id: primary_accountable_id) do
      primary_accountable = Pointers.follow!(pointer)
      {:ok, EconomicResource.change_primary_accountable(changeset, primary_accountable)}
    end
  end

  defp change_primary_accountable(changeset, _attrs), do: {:ok, changeset}

  defp change_receiver(changeset, %{receiver: receiver_id}) do
    with {:ok, pointer} <- Pointers.one(id: receiver_id) do
      receiver = Pointers.follow!(pointer)
      {:ok, EconomicResource.change_receiver(changeset, receiver)}
    end
  end

  defp change_receiver(changeset, _attrs), do: {:ok, changeset}

  defp change_action(changeset, %{state: state_id}) do
    with {:ok, state} <- Actions.action(state_id) do
      {:ok, EconomicResource.change_action(changeset, state)}
    end
  end

  defp change_action(changeset, _attrs), do: {:ok, changeset}

  defp change_current_location(changeset, %{current_location: id}) do
    with {:ok, location} <- Geolocations.one([:default, id: id]) do
      {:ok, EconomicResource.change_current_location(changeset, location)}
    end
  end

  defp change_current_location(changeset, _attrs), do: {:ok, changeset}

  defp parse_measurement_attrs(attrs) do
    Enum.reduce(attrs, %{}, fn {k, v}, acc ->
      if is_map(v) and Map.has_key?(v, :has_unit) do
        v = ValueFlows.Util.map_key_replace(v, :has_unit, :unit_id)
        # I have no idea why the numerical value isn't auto converted
        Map.put(acc, k, v)
      else
        Map.put(acc, k, v)
      end
    end)
  end
end
