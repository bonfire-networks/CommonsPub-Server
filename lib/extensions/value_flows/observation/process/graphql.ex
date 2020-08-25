# SPDX-License-Identifier: AGPL-3.0-only
defmodule ValueFlows.Observation.Process.GraphQL do
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

  alias ValueFlows.Observation.Process
  alias ValueFlows.Observation.Process.Processes
  alias ValueFlows.Observation.Process.Queries
  alias ValueFlows.Knowledge.Action.Actions
  # alias MoodleNetWeb.GraphQL.CommonResolver
  alias MoodleNetWeb.GraphQL.UploadResolver

  # SDL schema import
  # import_sdl path: "lib/value_flows/graphql/schemas/planning.gql"

  # TODO: put in config
  # @tags_seperator " "

  ## resolvers

  def simulate(%{id: id}, _) do
    {:ok, ValueFlows.Simulate.process()}
  end

  def simulate(_, _) do
    {:ok, CommonsPub.Utils.Trendy.some(1..5, &ValueFlows.Simulate.process/0)}
  end

  def process(%{id: id}, info) do
    ResolveField.run(%ResolveField{
      module: __MODULE__,
      fetcher: :fetch_process,
      context: id,
      info: info
    })
  end

  def processes(page_opts, info) do
    ResolveRootPage.run(%ResolveRootPage{
      module: __MODULE__,
      fetcher: :fetch_processes,
      page_opts: page_opts,
      info: info,
      # popularity
      cursor_validators: [&(is_integer(&1) and &1 >= 0), &Ecto.ULID.cast/1]
    })
  end

  def all_processes(_, _) do
    Processes.many()
  end

  def processes_filtered(page_opts, _) do
    IO.inspect(processes_filtered: page_opts)
    processes_filter(page_opts, [])
  end

  # def processes_filtered(page_opts, _) do
  #   IO.inspect(unhandled_filtering: page_opts)
  #   all_processes(page_opts, nil)
  # end

  # TODO: support several filters combined, plus pagination on filtered queries

  defp processes_filter(%{agent: id} = page_opts, filters_acc) do
    processes_filter_next(:agent, [agent_id: id], page_opts, filters_acc)
  end

  defp processes_filter(%{provider: id} = page_opts, filters_acc) do
    processes_filter_next(:provider, [provider_id: id], page_opts, filters_acc)
  end

  defp processes_filter(%{receiver: id} = page_opts, filters_acc) do
    processes_filter_next(:receiver, [receiver_id: id], page_opts, filters_acc)
  end

  defp processes_filter(%{action: id} = page_opts, filters_acc) do
    processes_filter_next(:action, [action_id: id], page_opts, filters_acc)
  end

  defp processes_filter(%{in_scope_of: context_id} = page_opts, filters_acc) do
    processes_filter_next(:in_scope_of, [context_id: context_id], page_opts, filters_acc)
  end

  defp processes_filter(%{tag_ids: tag_ids} = page_opts, filters_acc) do
    processes_filter_next(:tag_ids, [tag_ids: tag_ids], page_opts, filters_acc)
  end

  defp processes_filter(%{at_location: at_location_id} = page_opts, filters_acc) do
    processes_filter_next(:at_location, [at_location_id: at_location_id], page_opts, filters_acc)
  end

  defp processes_filter(
         %{
           geolocation: %{
             near_point: %{lat: lat, long: long},
             distance: %{meters: distance_meters}
           }
         } = page_opts,
         filters_acc
       ) do
    IO.inspect(geo_with_point: page_opts)

    processes_filter_next(
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

  defp processes_filter(
         %{
           geolocation: %{near_address: address} = geolocation
         } = page_opts,
         filters_acc
       ) do
    IO.inspect(geo_with_address: page_opts)

    with {:ok, coords} <- Geocoder.call(address) do
      # IO.inspect(coords)

      processes_filter(
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
        processes_filter_next(
          :geolocation,
          [],
          page_opts,
          filters_acc
        )
    end
  end

  defp processes_filter(
         %{
           geolocation: geolocation
         } = page_opts,
         filters_acc
       ) do
    IO.inspect(geo_without_distance: page_opts)

    processes_filter(
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

  defp processes_filter(
         _,
         filters_acc
       ) do
    IO.inspect(filters_query: filters_acc)

    # finally, if there's no more known params to acumulate, query with the filters
    Processes.many(filters_acc)
  end

  defp processes_filter_next(param_remove, filter_add, page_opts, filters_acc)
       when is_list(param_remove) and is_list(filter_add) do
    IO.inspect(processes_filter_next: param_remove)
    IO.inspect(processes_filter_add: filter_add)

    processes_filter(Map.drop(page_opts, param_remove), filters_acc ++ filter_add)
  end

  defp processes_filter_next(param_remove, filter_add, page_opts, filters_acc)
       when not is_list(filter_add) do
    processes_filter_next(param_remove, [filter_add], page_opts, filters_acc)
  end

  defp processes_filter_next(param_remove, filter_add, page_opts, filters_acc)
       when not is_list(param_remove) do
    processes_filter_next([param_remove], filter_add, page_opts, filters_acc)
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

  def fetch_process(info, id) do
    Processes.one([
      :default,
      user: GraphQL.current_user(info),
      id: id
      # preload: :tags
    ])
  end

  def creator_processes_edge(%{creator: creator}, %{} = page_opts, info) do
    ResolvePages.run(%ResolvePages{
      module: __MODULE__,
      fetcher: :fetch_creator_processes_edge,
      context: creator,
      page_opts: page_opts,
      info: info
    })
  end

  def fetch_creator_processes_edge(page_opts, info, ids) do
    list_processes(
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

  def list_processes(page_opts, base_filters, _data_filters, _cursor_type) do
    FetchPage.run(%FetchPage{
      queries: Queries,
      query: Process,
      # cursor_fn: Processes.cursor(cursor_type),
      page_opts: page_opts,
      base_filters: base_filters
      # data_filters: data_filters
    })
  end

  def fetch_processes(page_opts, info) do
    FetchPage.run(%FetchPage{
      queries: ValueFlows.Observation.Process.Queries,
      query: ValueFlows.Observation.Process,
      # preload: [:provider, :receiver, :tags],
      # cursor_fn: Processes.cursor(:followers),
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
      queries: ValueFlows.Observation.Process.Queries,
      query: ValueFlows.Observation.Process,
      page_opts: page_opts,
      base_filters: [
        [:default, :offer],
        user: GraphQL.current_user(info)
      ]
    })
  end

  def fetch_needs(page_opts, info) do
    FetchPage.run(%FetchPage{
      queries: ValueFlows.Observation.Process.Queries,
      query: ValueFlows.Observation.Process,
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

  def create_offer(%{process: process_attrs}, info) do
    with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info) do
      create_process(
        %{process: Map.put(process_attrs, :provider, user.id)},
        info
      )
    end
  end

  def create_need(%{process: process_attrs}, info) do
    with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info) do
      create_process(
        %{process: Map.put(process_attrs, :receiver, user.id)},
        info
      )
    end
  end

  def create_process(%{process: %{in_scope_of: context_ids} = process_attrs}, info)
      when is_list(context_ids) do
    # FIXME: support multiple contexts?
    context_id = List.first(context_ids)

    create_process(
      %{process: Map.merge(process_attrs, %{in_scope_of: context_id})},
      info
    )
  end

  def create_process(
        %{process: %{in_scope_of: context_id, action: action_id} = process_attrs},
        info
      )
      when not is_nil(context_id) do
    # FIXME, need to do something like validate_thread_context to validate the provider/receiver agent ID
    Repo.transact_with(fn ->
      with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info),
           {:ok, action} <- Actions.action(action_id),
           {:ok, pointer} <- Pointers.one(id: context_id),
           context = Pointers.follow!(pointer),
           {:ok, uploads} <- UploadResolver.upload(user, process_attrs, info),
           process_attrs = Map.merge(process_attrs, uploads),
           process_attrs = Map.merge(process_attrs, %{is_public: true}),
           {:ok, process} <- Processes.create(user, action, context, process_attrs) do
        {:ok, %{process: %{process | action: action}}}
      end
    end)
  end

  # FIXME: duplication!
  def create_process(%{process: %{action: action_id} = process_attrs}, info) do
    Repo.transact_with(fn ->
      with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info),
           {:ok, action} <- Actions.action(action_id),
           {:ok, uploads} <- UploadResolver.upload(user, process_attrs, info),
           process_attrs = Map.merge(process_attrs, uploads),
           process_attrs = Map.merge(process_attrs, %{is_public: true}),
           {:ok, process} <- Processes.create(user, action, process_attrs) do
        {:ok, %{process: %{process | action: action}}}
      end
    end)
  end

  def update_process(%{process: %{in_scope_of: context_ids} = changes}, info) do
    context_id = List.first(context_ids)

    Repo.transact_with(fn ->
      do_update(changes, info, fn process, changes ->
        with {:ok, pointer} <- Pointers.one(id: context_id) do
          context = Pointers.follow!(pointer)
          Processes.update(process, context, changes)
        end
      end)
    end)
  end

  def update_process(%{process: changes}, info) do
    Repo.transact_with(fn ->
      do_update(changes, info, fn process, changes ->
        Processes.update(process, changes)
      end)
    end)
  end

  defp do_update(%{id: id} = changes, info, update_fn) do
    with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info),
         {:ok, process} <- process(%{id: id}, info),
         :ok <- ensure_update_permission(user, process),
         {:ok, uploads} <- UploadResolver.upload(user, changes, info),
         changes = Map.merge(changes, uploads),
         {:ok, process} <- update_fn.(process, changes) do
      {:ok, %{process: process}}
    end
  end

  def delete_process(%{id: id}, info) do
    Repo.transact_with(fn ->
      with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info),
           {:ok, process} <- process(%{id: id}, info),
           :ok <- ensure_update_permission(user, process),
           {:ok, _} <- Processes.soft_delete(process) do
        {:ok, true}
      end
    end)
  end

  def ensure_update_permission(user, process) do
    if user.local_user.is_instance_admin or process.creator_id == user.id do
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
