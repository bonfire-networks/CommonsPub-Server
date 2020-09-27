# SPDX-License-Identifier: AGPL-3.0-only
defmodule ValueFlows.Observation.EconomicEvent.EconomicEvents do
  alias CommonsPub.{Activities, Common, Feeds, Repo}
  alias CommonsPub.GraphQL.{Fields, Page}
  alias CommonsPub.Common.Contexts
  alias CommonsPub.Feeds.FeedActivities
  alias CommonsPub.Users.User
  alias CommonsPub.Meta.Pointers

  alias Geolocation.Geolocations
  # alias Measurement.Measure
  # alias ValueFlows.Knowledge.Action
  alias ValueFlows.Knowledge.Action.Actions
  alias ValueFlows.Knowledge.ResourceSpecification.ResourceSpecifications
  alias ValueFlows.Observation.EconomicEvent
  alias ValueFlows.Observation.EconomicResource.EconomicResources
  alias ValueFlows.Observation.EconomicEvent.Queries
  alias ValueFlows.Observation.Process.Processes

  def cursor(), do: &[&1.id]
  def test_cursor(), do: &[&1["id"]]

  @doc """
  Retrieves a single one by arbitrary filters.
  Used by:
  * GraphQL Item queries
  * ActivityPub integration
  * Various parts of the codebase that need to query for this (inc. tests)
  """
  def one(filters), do: Repo.single(Queries.query(EconomicEvent, filters))

  @doc """
  Retrieves a list of them by arbitrary filters.
  Used by:
  * Various parts of the codebase that need to query for this (inc. tests)
  """
  def many(filters \\ []), do: {:ok, Repo.all(Queries.query(EconomicEvent, filters))}

  def fields(group_fn, filters \\ [])
      when is_function(group_fn, 1) do
    {:ok, fields} = many(filters)
    {:ok, Fields.new(fields, group_fn)}
  end

  @doc """
  Retrieves an Page of events according to various filters

  Used by:
  * GraphQL resolver single-parent resolution
  """
  def page(cursor_fn, page_opts, base_filters \\ [], data_filters \\ [], count_filters \\ [])

  def page(cursor_fn, %{} = page_opts, base_filters, data_filters, count_filters) do
    base_q = Queries.query(EconomicEvent, base_filters)
    data_q = Queries.filter(base_q, data_filters)
    count_q = Queries.filter(base_q, count_filters)

    with {:ok, [data, counts]} <- Repo.transact_many(all: data_q, count: count_q) do
      {:ok, Page.new(data, counts, cursor_fn, page_opts)}
    end
  end

  @doc """
  Retrieves an Pages of events according to various filters

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
      EconomicEvent,
      cursor_fn,
      group_fn,
      page_opts,
      base_filters,
      data_filters,
      count_filters
    )
  end

  ## mutations

  def create(creator, receiver, provider, action, event_attrs, %{
        new_inventoried_resource: new_inventoried_resource
      }) do
    new_inventoried_resource = Map.merge(new_inventoried_resource, %{is_public: true})

    with {:ok, resource} <-
           ValueFlows.Observation.EconomicResource.EconomicResources.create(
             creator,
             new_inventoried_resource
           ) do
      event_attrs = Map.merge(event_attrs, %{resource_inventoried_as: resource})
      create(creator, receiver, provider, action, event_attrs)
    end
  end

  def create(%User{} = creator, receiver, provider, action, event_attrs) do
    changeset_fn = fn ->
      EconomicEvent.create_changeset(creator, receiver, provider, action, event_attrs)
    end
    Repo.transact_with(fn ->
      with {:ok, cs} <- prepare_changeset(event_attrs, changeset_fn),
           {:ok, item} <- Repo.insert(cs),
           {:ok, item} <- ValueFlows.Util.try_tag_thing(creator, item, event_attrs),
           act_attrs = %{verb: "created", is_local: true},
           # FIXME
           {:ok, activity} <- Activities.create(creator, item, act_attrs),
           :ok <- publish(creator, item, activity, :created) do
        item = %{item | creator: creator, receiver: receiver, provider: provider, action: action}
        index(item)
        {:ok, item}
      end
    end)
  end

  # TODO: take the user who is performing the update
  # @spec update(%EconomicEvent{}, attrs :: map) :: {:ok, EconomicEvent.t()} | {:error, Changeset.t()}
  def update(%EconomicEvent{} = event, attrs) do
    do_update(event, attrs, &EconomicEvent.update_changeset(&1, attrs))
  end

  def do_update(event, attrs, changeset_fn) do
    Repo.transact_with(fn ->
      event =
        Repo.preload(event, [
          :available_quantity,
          :resource_quantity,
          :effort_quantity,
          :at_location
        ])

      with {:ok, cs} <- prepare_changeset(attrs, changeset_fn, event),
           {:ok, event} <- Repo.update(cs),
           {:ok, event} <- ValueFlows.Util.try_tag_thing(nil, event, attrs),
           :ok <- publish(event, :updated) do
        {:ok, event}
      end
    end)
  end

  defp prepare_changeset(attrs, changeset_fn, event) do
    event
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
      {:measures, &EconomicEvent.change_measures/2},
      {:context, &change_context/2},
      {:provider, &change_provider/2},
      {:receiver, &change_receiver/2},
      {:action, &change_action/2},
      {:location, &change_at_location/2},
      {:input_of, &change_input_of/2},
      {:output_of, &change_output_of/2},
      {:triggered_by, &change_triggered_by_event/2},
      {:resource_spec, &change_resource_conforms_to/2},
      {:resource_inventoried_as, &change_resource_inventoried_as/2},
      {:change_to_resource_inventoried_as, &change_to_resource_inventoried_as/2},
    ])
  end


  defp change_context(changeset, %{in_scope_of: context_ids} = attrs)
       when is_list(context_ids) do
    # FIXME: support multiple contexts?
    context_id = List.first(context_ids)

    change_context(
      changeset,
      Map.merge(attrs, %{in_scope_of: context_id})
    )
  end

  defp change_context(changeset, %{in_scope_of: id}) do
    with {:ok, pointer} <- Pointers.one(id: id) do
      EconomicEvent.change_context(changeset, pointer)
    end
  end

  defp change_context(changeset, _attrs), do: changeset

  defp change_resource_conforms_to(changeset, %{resource_conforms_to: id}) do
    with {:ok, item} <- ResourceSpecifications.one([:default, id: id]) do
      EconomicEvent.change_resource_conforms_to(changeset, item)
    end
  end

  defp change_resource_conforms_to(changeset, _attrs), do: changeset

  defp change_resource_inventoried_as(changeset, %{resource_inventoried_as: id})
       when is_binary(id) do
    with {:ok, item} <- EconomicResources.one([:default, id: id]) do
      EconomicEvent.change_resource_inventoried_as(changeset, item)
    end
  end

  defp change_resource_inventoried_as(changeset, %{resource_inventoried_as: %{} = resource}) do
    EconomicEvent.change_resource_inventoried_as(changeset, resource)
  end

  defp change_resource_inventoried_as(changeset, _attrs), do: changeset

  defp change_to_resource_inventoried_as(changeset, %{to_resource_inventoried_as: id}) do
    with {:ok, item} <- EconomicResources.one([:default, id: id]) do
      EconomicEvent.change_to_resource_inventoried_as(changeset, item)
    end
  end

  defp change_to_resource_inventoried_as(changeset, _attrs), do: changeset

  defp change_provider(changeset, %{provider: provider_id}) do
    with {:ok, pointer} <- Pointers.one(id: provider_id) do
      provider = Pointers.follow!(pointer)
      EconomicEvent.change_provider(changeset, provider)
    end
  end

  defp change_provider(changeset, _attrs), do: changeset

  defp change_receiver(changeset, %{receiver: receiver_id}) do
    with {:ok, pointer} <- Pointers.one(id: receiver_id) do
      receiver = Pointers.follow!(pointer)
      EconomicEvent.change_receiver(changeset, receiver)
    end
  end

  defp change_receiver(changeset, _attrs), do: changeset

  defp change_action(changeset, %{action: action_id}) do
    with {:ok, action} <- Actions.action(action_id) do
      EconomicEvent.change_action(changeset, action)
    end
  end

  defp change_action(changeset, _attrs), do: changeset


  defp change_input_of(changeset, %{input_of: id}) do
    with {:ok, input_of} <- Processes.one([:default, id: id]) do
      EconomicEvent.change_input_process(changeset, input_of)
    end
  end

  defp change_input_of(changeset, _attrs), do: changeset



  defp change_output_of(changeset, %{output_of: id}) do
    with {:ok, output_of} <- Processes.one([:default, id: id]) do
      EconomicEvent.change_output_process(changeset, output_of)
    end
  end

  defp change_output_of(changeset, _attrs), do: changeset


  defp change_at_location(changeset, %{at_location: id}) do
    with {:ok, location} <- Geolocations.one([:default, id: id]) do
      EconomicEvent.change_at_location(changeset, location)
    end
  end

  defp change_at_location(changeset, _attrs), do: changeset

  defp change_triggered_by_event(changeset, %{triggered_by: id}) do
    with {:ok, triggered_by} <- one([:default, id: id]) do
      EconomicEvent.change_triggered_by_event(changeset, triggered_by)
    end
  end

  defp change_triggered_by_event(changeset, _attrs), do: changeset


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

  def soft_delete(%EconomicEvent{} = event) do
    Repo.transact_with(fn ->
      with {:ok, event} <- Common.soft_delete(event),
           :ok <- publish(event, :deleted) do
        {:ok, event}
      end
    end)
  end

  defp publish(creator, event, activity, :created) do
    feeds = [
      CommonsPub.Feeds.outbox_id(creator),
      Feeds.instance_outbox_id()
    ]

    with :ok <- FeedActivities.publish(activity, feeds) do
      ap_publish("create", event.id, creator.id)
    end
  end

  defp publish(creator, context, event, activity, :created) do
    feeds = [
      context.outbox_id,
      CommonsPub.Feeds.outbox_id(creator),
      Feeds.instance_outbox_id()
    ]

    with :ok <- FeedActivities.publish(activity, feeds) do
      ap_publish("create", event.id, creator.id)
    end
  end

  defp publish(event, :updated) do
    # TODO: wrong if edited by admin
    ap_publish("update", event.id, event.creator_id)
  end

  defp publish(event, :deleted) do
    # TODO: wrong if edited by admin
    ap_publish("delete", event.id, event.creator_id)
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
    %{
      "index_type" => "EconomicEvent",
      "id" => obj.id,
      # "canonicalUrl" => obj.character.canonical_url,
      # "icon" => icon,
      "summary" => Map.get(obj, :note),
      "published_at" => obj.published_at,
      "creator" => CommonsPub.Search.Indexer.format_creator(obj)
      # "index_instance" => URI.parse(obj.character.canonical_url).host, # home instance of object
    }
  end

  defp index(obj) do
    object = indexing_object_format(obj)

    CommonsPub.Search.Indexer.index_object(object)

    :ok
  end
end
