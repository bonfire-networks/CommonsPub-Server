# SPDX-License-Identifier: AGPL-3.0-only
defmodule ValueFlows.Observation.EconomicResource.EconomicResources do
  alias __MODULE__
  alias CommonsPub.{Activities, Common, Feeds, Repo}
  alias CommonsPub.GraphQL.{Fields, Page}
  alias CommonsPub.Common.Contexts
  alias CommonsPub.Feeds.FeedActivities
  alias CommonsPub.Users.User
  alias CommonsPub.Meta.Pointers

  alias Geolocation.Geolocations
  # alias Measurement.Measure
  alias Measurement.Unit.Units
  alias ValueFlows.Knowledge.ResourceSpecification.ResourceSpecifications
  alias ValueFlows.Knowledge.ProcessSpecification.ProcessSpecifications
  alias ValueFlows.Observation.EconomicResource
  alias ValueFlows.Observation.EconomicResource.Queries
  # alias ValueFlows.Knowledge.Action
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

  def preload_all(resource) do
    Repo.preload(resource, [
      :accounting_quantity,
      :onhand_quantity,
      :unit_of_effort,
      # :state,
      :primary_accountable,
      :current_location,
      :contained_in,
      :conforms_to
    ]) |> Map.put :state, ValueFlows.Knowledge.Action.Actions.action!(resource.state_id)
  end

  ## mutations

  # @spec create(User.t(), attrs :: map) :: {:ok, EconomicResource.t()} | {:error, Changeset.t()}
  def create(%User{} = creator, attrs) when is_map(attrs) do
    do_create(creator, attrs, fn ->
      EconomicResource.create_changeset(creator, attrs)
    end)
  end

  def do_create(creator, attrs, changeset_fn) do
    Repo.transact_with(fn ->
      with {:ok, cs} <- prepare_changeset(attrs, changeset_fn),
           {:ok, item} <- Repo.insert(cs),
           {:ok, item} <- ValueFlows.Util.try_tag_thing(creator, item, attrs),
           act_attrs = %{verb: "created", is_local: true},
           # FIXME
           {:ok, activity} <- Activities.create(creator, item, act_attrs),
           :ok <- publish(creator, item, activity, :created) do
        item = %{item | creator: creator}
        item = preload_all(item)

        index(item)
        {:ok, item}
      end
    end)
  end


  # TODO: take the user who is performing the update
  # @spec update(%EconomicResource{}, attrs :: map) :: {:ok, EconomicResource.t()} | {:error, Changeset.t()}
  def update(%EconomicResource{} = resource, attrs) do
    do_update(resource, attrs, &EconomicResource.update_changeset(&1, attrs))
  end

  def do_update(resource, attrs, changeset_fn) do
    Repo.transact_with(fn ->
      resource = preload_all(resource)

      with {:ok, cs} <- prepare_changeset(attrs, changeset_fn, resource),
           {:ok, resource} <- Repo.update(cs),
           {:ok, resource} <- ValueFlows.Util.try_tag_thing(nil, resource, attrs),
           :ok <- publish(resource, :updated) do
        {:ok, resource}
      end
    end)
  end


  defp prepare_changeset(attrs, changeset_fn, resource) do
    resource
    |> changeset_fn.()
    |> changeset_relations(attrs)
  end

  defp prepare_changeset(attrs, changeset_fn) do
    changeset_fn.()
    |> changeset_relations(attrs)
  end

  defp changeset_relations(cs, attrs) do
    attrs = parse_measurement_attrs(attrs)
    ValueFlows.Util.handle_changeset_errors(cs, attrs, [
    {:measures, &EconomicResource.change_measures/2},
    {:primary_accountable, &change_primary_accountable/2},
    {:state_action, &change_state_action/2},
    {:location, &change_current_location/2},
    {:conforms_to_resource_spec, &change_conforms_to_resource_spec/2},
    {:contained_in_resource, &change_contained_in_resource/2},
    {:unit_of_effort, &change_unit_of_effort/2},
    ])
  end

  defp change_primary_accountable(changeset, %{primary_accountable: id}) do
    with {:ok, pointer} <- Pointers.one(id: id) do
      primary_accountable = Pointers.follow!(pointer)
      EconomicResource.change_primary_accountable(changeset, primary_accountable)
    end
  end

  defp change_primary_accountable(changeset, _attrs), do: changeset

  defp change_state_action(changeset, %{state: state_id}) do
    with {:ok, state} <- Actions.action(state_id) do
      EconomicResource.change_state_action(changeset, state)
    end
  end

  defp change_state_action(changeset, _attrs), do: changeset

  defp change_current_location(changeset, %{current_location: id}) do
    with {:ok, location} <- Geolocations.one([:default, id: id]) do
      EconomicResource.change_current_location(changeset, location)
    end
  end

  defp change_current_location(changeset, _attrs), do: changeset

  defp change_conforms_to_resource_spec(changeset, %{conforms_to: id}) do
    with {:ok, item} <- ResourceSpecifications.one([:default, id: id]) do
      EconomicResource.change_conforms_to_resource_spec(changeset, item)
    end
  end

  defp change_conforms_to_resource_spec(changeset, _attrs), do: changeset

  defp change_contained_in_resource(changeset, %{contained_in: id}) do
    with {:ok, item} <- EconomicResources.one([:default, id: id]) do
      EconomicResource.change_contained_in_resource(changeset, item)
    end
  end

  defp change_contained_in_resource(changeset, _attrs), do: changeset

  defp change_unit_of_effort(changeset, %{unit_of_effort: id}) do
    with {:ok, item} <- Units.one([:default, id: id]) do
      EconomicResource.change_unit_of_effort(changeset, item)
    end
  end

  defp change_unit_of_effort(changeset, _attrs), do: changeset

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

  def soft_delete(%EconomicResource{} = resource) do
    Repo.transact_with(fn ->
      with {:ok, resource} <- Common.soft_delete(resource),
           :ok <- publish(resource, :deleted) do
        {:ok, resource}
      end
    end)
  end

  defp publish(creator, resource, activity, :created) do
    feeds = [
      CommonsPub.Feeds.outbox_id(creator),
      Feeds.instance_outbox_id()
    ]

    with :ok <- FeedActivities.publish(activity, feeds) do
      ap_publish("create", resource.id, creator.id)
    end
  end

  defp publish(creator, context, resource, activity, :created) do
    feeds = [
      context.outbox_id,
      CommonsPub.Feeds.outbox_id(creator),
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
    CommonsPub.Workers.APPublishWorker.enqueue(verb, %{
      "context_id" => context_id,
      "user_id" => user_id
    })

    :ok
  end

  defp ap_publish(_, _, _), do: :ok

  def indexing_object_format(obj) do
    # icon = CommonsPub.Uploads.remote_url_from_id(obj.icon_id)
    image = CommonsPub.Uploads.remote_url_from_id(obj.image_id)

    %{
      "index_type" => "EconomicResource",
      "id" => obj.id,
      # "canonicalUrl" => obj.canonical_url,
      # "icon" => icon,
      "image" => image,
      "name" => obj.name,
      "summary" => Map.get(obj, :note),
      "published_at" => obj.published_at,
      "creator" => CommonsPub.Search.Indexer.format_creator(obj)
      # "index_instance" => URI.parse(obj.canonical_url).host, # home instance of object
    }
  end

  defp index(obj) do
    object = indexing_object_format(obj)

    CommonsPub.Search.Indexer.index_object(object)

    :ok
  end
end
