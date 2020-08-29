# SPDX-License-Identifier: AGPL-3.0-only
defmodule ValueFlows.Knowledge.ProcessSpecification.GraphQL do
  use Absinthe.Schema.Notation

  # default to 100 km radius
  @radius_default_distance 100_000

  require Logger
  # import ValueFlows.Util, only: [maybe_put: 3]

  alias MoodleNet.{
    # Activities,
    # Communities,
    GraphQL,
    Repo
    # User
  }

  alias MoodleNet.GraphQL.{
    ResolveField,
    # ResolveFields,
    # ResolvePage,
    ResolvePages,
    ResolveRootPage,
    FetchPage
    # FetchPages,
    # CommonResolver
  }

  # alias MoodleNet.Resources.Resource
  # alias MoodleNet.Common.Enums
  alias MoodleNet.Meta.Pointers
  # alias MoodleNet.Communities.Community
  # alias MoodleNetWeb.GraphQL.CommunitiesResolver

  alias ValueFlows.Knowledge.ProcessSpecification
  alias ValueFlows.Knowledge.ProcessSpecification.ProcessSpecifications
  alias ValueFlows.Knowledge.ProcessSpecification.Queries
  alias ValueFlows.Knowledge.Action.Actions
  # alias MoodleNetWeb.GraphQL.CommonResolver
  alias MoodleNetWeb.GraphQL.UploadResolver

  # SDL schema import
  # import_sdl path: "lib/value_flows/graphql/schemas/planning.gql"

  # TODO: put in config
  # @tags_seperator " "

  ## resolvers

  def simulate(%{id: id}, _) do
    {:ok, ValueFlows.Simulate.process_spec()}
  end

  def simulate(_, _) do
    {:ok, CommonsPub.Utils.Trendy.some(1..5, &ValueFlows.Simulate.process_spec/0)}
  end

  def process_spec(%{id: id}, info) do
    ResolveField.run(%ResolveField{
      module: __MODULE__,
      fetcher: :fetch_process_spec,
      context: id,
      info: info
    })
  end

  def process_specs(page_opts, info) do
    ResolveRootPage.run(%ResolveRootPage{
      module: __MODULE__,
      fetcher: :fetch_process_specs,
      page_opts: page_opts,
      info: info,
      # popularity
      cursor_validators: [&(is_integer(&1) and &1 >= 0), &Ecto.ULID.cast/1]
    })
  end

  def all_process_specs(_, _) do
    ProcessSpecifications.many()
  end

  def process_specs_filtered(page_opts, _) do
    IO.inspect(process_specs_filtered: page_opts)
    process_specs_filter(page_opts, [])
  end

  # def process_specs_filtered(page_opts, _) do
  #   IO.inspect(unhandled_filtering: page_opts)
  #   all_process_specs(page_opts, nil)
  # end

  # TODO: support several filters combined, plus pagination on filtered queries

  defp process_specs_filter(%{agent: id} = page_opts, filters_acc) do
    process_specs_filter_next(:agent, [agent_id: id], page_opts, filters_acc)
  end

  defp process_specs_filter(%{provider: id} = page_opts, filters_acc) do
    process_specs_filter_next(:provider, [provider_id: id], page_opts, filters_acc)
  end

  defp process_specs_filter(%{receiver: id} = page_opts, filters_acc) do
    process_specs_filter_next(:receiver, [receiver_id: id], page_opts, filters_acc)
  end

  defp process_specs_filter(%{action: id} = page_opts, filters_acc) do
    process_specs_filter_next(:action, [action_id: id], page_opts, filters_acc)
  end

  defp process_specs_filter(%{in_scope_of: context_id} = page_opts, filters_acc) do
    process_specs_filter_next(:in_scope_of, [context_id: context_id], page_opts, filters_acc)
  end

  defp process_specs_filter(%{tag_ids: tag_ids} = page_opts, filters_acc) do
    process_specs_filter_next(:tag_ids, [tag_ids: tag_ids], page_opts, filters_acc)
  end

  defp process_specs_filter(%{at_location: at_location_id} = page_opts, filters_acc) do
    process_specs_filter_next(
      :at_location,
      [at_location_id: at_location_id],
      page_opts,
      filters_acc
    )
  end

  defp process_specs_filter(
         %{
           geolocation: %{
             near_point: %{lat: lat, long: long},
             distance: %{meters: distance_meters}
           }
         } = page_opts,
         filters_acc
       ) do
    IO.inspect(geo_with_point: page_opts)

    process_specs_filter_next(
      :geolocation,
      {
        :near_point,
        %Geo.Point{coordinates: {lat, long}, srid: 4326},
        :distance_meters,
        distance_meters
      },
      page_opts,
      filters_acc
    )
  end

  defp process_specs_filter(
         %{
           geolocation: %{near_address: address} = geolocation
         } = page_opts,
         filters_acc
       ) do
    IO.inspect(geo_with_address: page_opts)

    with {:ok, coords} <- Geocoder.call(address) do
      # IO.inspect(coords)

      process_specs_filter(
        Map.merge(
          page_opts,
          %{
            geolocation:
              Map.merge(geolocation, %{
                near_point: %{lat: coords.lat, long: coords.lon},
                distance: Map.get(geolocation, :distance, %{meters: @radius_default_distance})
              })
          }
        ),
        filters_acc
      )
    else
      _ ->
        process_specs_filter_next(
          :geolocation,
          [],
          page_opts,
          filters_acc
        )
    end
  end

  defp process_specs_filter(
         %{
           geolocation: geolocation
         } = page_opts,
         filters_acc
       ) do
    IO.inspect(geo_without_distance: page_opts)

    process_specs_filter(
      Map.merge(
        page_opts,
        %{
          geolocation:
            Map.merge(geolocation, %{
              # default to 100 km radius
              distance: %{meters: @radius_default_distance}
            })
        }
      ),
      filters_acc
    )
  end

  defp process_specs_filter(
         _,
         filters_acc
       ) do
    IO.inspect(filters_query: filters_acc)

    # finally, if there's no more known params to acumulate, query with the filters
    ProcessSpecifications.many(filters_acc)
  end

  defp process_specs_filter_next(param_remove, filter_add, page_opts, filters_acc)
       when is_list(param_remove) and is_list(filter_add) do
    IO.inspect(process_specs_filter_next: param_remove)
    IO.inspect(process_specs_filter_add: filter_add)

    process_specs_filter(Map.drop(page_opts, param_remove), filters_acc ++ filter_add)
  end

  defp process_specs_filter_next(param_remove, filter_add, page_opts, filters_acc)
       when not is_list(filter_add) do
    process_specs_filter_next(param_remove, [filter_add], page_opts, filters_acc)
  end

  defp process_specs_filter_next(param_remove, filter_add, page_opts, filters_acc)
       when not is_list(param_remove) do
    process_specs_filter_next([param_remove], filter_add, page_opts, filters_acc)
  end

  def offers(page_opts, info) do
    ResolveRootPage.run(%ResolveRootPage{
      module: __MODULE__,
      fetcher: :fetch_offers,
      page_opts: page_opts,
      info: info,
      # popularity
      cursor_validators: [&(is_integer(&1) and &1 >= 0), &Ecto.ULID.cast/1]
    })
  end

  def needs(page_opts, info) do
    ResolveRootPage.run(%ResolveRootPage{
      module: __MODULE__,
      fetcher: :fetch_needs,
      page_opts: page_opts,
      info: info,
      # popularity
      cursor_validators: [&(is_integer(&1) and &1 >= 0), &Ecto.ULID.cast/1]
    })
  end

  ## fetchers

  def fetch_process_spec(info, id) do
    ProcessSpecifications.one([
      :default,
      user: GraphQL.current_user(info),
      id: id
      # preload: :tags
    ])
  end

  def creator_process_specs_edge(%{creator: creator}, %{} = page_opts, info) do
    ResolvePages.run(%ResolvePages{
      module: __MODULE__,
      fetcher: :fetch_creator_process_specs_edge,
      context: creator,
      page_opts: page_opts,
      info: info
    })
  end

  def fetch_creator_process_specs_edge(page_opts, info, ids) do
    list_process_specs(
      page_opts,
      [
        :default,
        agent_id: ids,
        user: GraphQL.current_user(info)
      ],
      nil,
      nil
    )
  end

  def list_process_specs(page_opts, base_filters, _data_filters, _cursor_type) do
    FetchPage.run(%FetchPage{
      queries: Queries,
      query: ProcessSpecification,
      # cursor_fn: ProcessSpecifications.cursor(cursor_type),
      page_opts: page_opts,
      base_filters: base_filters
      # data_filters: data_filters
    })
  end

  def fetch_process_specs(page_opts, info) do
    FetchPage.run(%FetchPage{
      queries: ValueFlows.Knowledge.ProcessSpecification.Queries,
      query: ValueFlows.Knowledge.ProcessSpecification,
      # preload: [:provider, :receiver, :tags],
      # cursor_fn: ProcessSpecifications.cursor(:followers),
      page_opts: page_opts,
      base_filters: [
        :default,
        # preload: [:provider, :receiver, :tags],
        user: GraphQL.current_user(info)
      ]
      # data_filters: [page: [desc: [followers: page_opts]]],
    })
  end

  def fetch_offers(page_opts, info) do
    FetchPage.run(%FetchPage{
      queries: ValueFlows.Knowledge.ProcessSpecification.Queries,
      query: ValueFlows.Knowledge.ProcessSpecification,
      page_opts: page_opts,
      base_filters: [
        [:default, :offer],
        user: GraphQL.current_user(info)
      ]
    })
  end

  def fetch_needs(page_opts, info) do
    FetchPage.run(%FetchPage{
      queries: ValueFlows.Knowledge.ProcessSpecification.Queries,
      query: ValueFlows.Knowledge.ProcessSpecification,
      page_opts: page_opts,
      base_filters: [
        [:default, :need],
        user: GraphQL.current_user(info)
      ]
    })
  end

  def fetch_provider_edge(%{provider_id: id}, _, info) when not is_nil(id) do
    # CommonResolver.context_edge(%{context_id: id}, nil, info)
    {:ok, ValueFlows.Agent.Agents.agent(id, GraphQL.current_user(info))}
  end

  def fetch_provider_edge(_, _, _) do
    {:ok, nil}
  end

  def fetch_receiver_edge(%{receiver_id: id}, _, info) when not is_nil(id) do
    # CommonResolver.context_edge(%{context_id: id}, nil, info)
    {:ok, ValueFlows.Agent.Agents.agent(id, GraphQL.current_user(info))}
  end

  def fetch_receiver_edge(_, _, _) do
    {:ok, nil}
  end

  def fetch_classifications_edge(%{tags: _tags} = thing, _, _) do
    thing = Repo.preload(thing, tags: [character: [:actor]])
    urls = Enum.map(thing.tags, & &1.character.actor.canonical_url)
    {:ok, urls}
  end

  def create_offer(%{process_spec: process_spec_attrs}, info) do
    with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info) do
      create_process_spec(
        %{process_spec: Map.put(process_spec_attrs, :provider, user.id)},
        info
      )
    end
  end

  def create_need(%{process_spec: process_spec_attrs}, info) do
    with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info) do
      create_process_spec(
        %{process_spec: Map.put(process_spec_attrs, :receiver, user.id)},
        info
      )
    end
  end

  def create_process_spec(%{process_spec: %{in_scope_of: context_ids} = process_spec_attrs}, info)
      when is_list(context_ids) do
    # FIXME: support multiple contexts?
    context_id = List.first(context_ids)

    create_process_spec(
      %{process_spec: Map.merge(process_spec_attrs, %{in_scope_of: context_id})},
      info
    )
  end

  def create_process_spec(
        %{process_spec: %{in_scope_of: context_id, action: action_id} = process_spec_attrs},
        info
      )
      when not is_nil(context_id) do
    # FIXME, need to do something like validate_thread_context to validate the provider/receiver agent ID
    Repo.transact_with(fn ->
      with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info),
           {:ok, action} <- Actions.action(action_id),
           {:ok, pointer} <- Pointers.one(id: context_id),
           context = Pointers.follow!(pointer),
           {:ok, uploads} <- UploadResolver.upload(user, process_spec_attrs, info),
           process_spec_attrs = Map.merge(process_spec_attrs, uploads),
           process_spec_attrs = Map.merge(process_spec_attrs, %{is_public: true}),
           {:ok, process_spec} <-
             ProcessSpecifications.create(user, action, context, process_spec_attrs) do
        {:ok, %{process_spec: %{process_spec | action: action}}}
      end
    end)
  end

  # FIXME: duplication!
  def create_process_spec(%{process_spec: %{action: action_id} = process_spec_attrs}, info) do
    Repo.transact_with(fn ->
      with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info),
           {:ok, action} <- Actions.action(action_id),
           {:ok, uploads} <- UploadResolver.upload(user, process_spec_attrs, info),
           process_spec_attrs = Map.merge(process_spec_attrs, uploads),
           process_spec_attrs = Map.merge(process_spec_attrs, %{is_public: true}),
           {:ok, process_spec} <- ProcessSpecifications.create(user, action, process_spec_attrs) do
        {:ok, %{process_spec: %{process_spec | action: action}}}
      end
    end)
  end

  def update_process_spec(%{process_spec: %{in_scope_of: context_ids} = changes}, info) do
    context_id = List.first(context_ids)

    Repo.transact_with(fn ->
      do_update(changes, info, fn process_spec, changes ->
        with {:ok, pointer} <- Pointers.one(id: context_id) do
          context = Pointers.follow!(pointer)
          ProcessSpecifications.update(process_spec, context, changes)
        end
      end)
    end)
  end

  def update_process_spec(%{process_spec: changes}, info) do
    Repo.transact_with(fn ->
      do_update(changes, info, fn process_spec, changes ->
        ProcessSpecifications.update(process_spec, changes)
      end)
    end)
  end

  defp do_update(%{id: id} = changes, info, update_fn) do
    with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info),
         {:ok, process_spec} <- process_spec(%{id: id}, info),
         :ok <- ensure_update_permission(user, process_spec),
         {:ok, uploads} <- UploadResolver.upload(user, changes, info),
         changes = Map.merge(changes, uploads),
         {:ok, process_spec} <- update_fn.(process_spec, changes) do
      {:ok, %{process_spec: process_spec}}
    end
  end

  def delete_process_spec(%{id: id}, info) do
    Repo.transact_with(fn ->
      with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info),
           {:ok, process_spec} <- process_spec(%{id: id}, info),
           :ok <- ensure_update_permission(user, process_spec),
           {:ok, _} <- ProcessSpecifications.soft_delete(process_spec) do
        {:ok, true}
      end
    end)
  end

  def ensure_update_permission(user, process_spec) do
    if user.local_user.is_instance_admin or process_spec.creator_id == user.id do
      :ok
    else
      GraphQL.not_permitted("update")
    end
  end

  # defp validate_agent(pointer) do
  #   if Pointers.table!(pointer).schema in valid_contexts() do
  #     :ok
  #   else
  #     GraphQL.not_permitted()
  #   end
  # end

  # defp valid_contexts() do
  #   [User, Community, Organisation]
  #   # Keyword.fetch!(Application.get_env(:moodle_net, Threads), :valid_contexts)
  # end
end
