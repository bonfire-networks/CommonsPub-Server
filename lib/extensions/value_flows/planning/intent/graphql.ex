# SPDX-License-Identifier: AGPL-3.0-only
defmodule ValueFlows.Planning.Intent.GraphQL do
  use Absinthe.Schema.Notation

  # default to 100 km radius
  @radius_default_distance 100_000

  require Logger
  # import ValueFlows.Util, only: [maybe_put: 3]

  alias CommonsPub.{
    # Activities,
    # Communities,
    GraphQL,
    Repo
    # User
  }

  alias CommonsPub.GraphQL.{
    ResolveField,
    # ResolveFields,
    # ResolvePage,
    ResolvePages,
    ResolveRootPage,
    FetchPage
    # FetchPages,
    # CommonResolver
  }

  # alias CommonsPub.Resources.Resource
  # alias CommonsPub.Common.Enums
  alias CommonsPub.Meta.Pointers
  # alias CommonsPub.Communities.Community
  # alias CommonsPub.Web.GraphQL.CommunitiesResolver

  alias ValueFlows.Planning.Intent
  alias ValueFlows.Planning.Intent.Intents
  alias ValueFlows.Planning.Intent.Queries
  alias ValueFlows.Knowledge.Action.Actions
  # alias CommonsPub.Web.GraphQL.CommonResolver
  alias CommonsPub.Web.GraphQL.UploadResolver

  # SDL schema import
  # import_sdl path: "lib/value_flows/graphql/schemas/planning.gql"

  # TODO: put in config
  # @tags_seperator " "

  ## resolvers

  def intent(%{id: id}, info) do
    ResolveField.run(%ResolveField{
      module: __MODULE__,
      fetcher: :fetch_intent,
      context: id,
      info: info
    })
  end

  def intents(page_opts, info) do
    ResolveRootPage.run(%ResolveRootPage{
      module: __MODULE__,
      fetcher: :fetch_intents,
      page_opts: page_opts,
      info: info,
      # popularity
      cursor_validators: [&(is_integer(&1) and &1 >= 0), &Ecto.ULID.cast/1]
    })
  end

  def all_intents(_, _) do
    Intents.many()
  end

  def intents_filtered(page_opts, _) do
    IO.inspect(intents_filtered: page_opts)
    intents_filter(page_opts, [])
  end

  # def intents_filtered(page_opts, _) do
  #   IO.inspect(unhandled_filtering: page_opts)
  #   all_intents(page_opts, nil)
  # end

  # TODO: support several filters combined, plus pagination on filtered queries

  defp intents_filter(%{agent: id} = page_opts, filters_acc) do
    intents_filter_next(:agent, [agent_id: id], page_opts, filters_acc)
  end

  defp intents_filter(%{provider: id} = page_opts, filters_acc) do
    intents_filter_next(:provider, [provider_id: id], page_opts, filters_acc)
  end

  defp intents_filter(%{receiver: id} = page_opts, filters_acc) do
    intents_filter_next(:receiver, [receiver_id: id], page_opts, filters_acc)
  end

  defp intents_filter(%{action: id} = page_opts, filters_acc) do
    intents_filter_next(:action, [action_id: id], page_opts, filters_acc)
  end

  defp intents_filter(%{in_scope_of: context_id} = page_opts, filters_acc) do
    intents_filter_next(:in_scope_of, [context_id: context_id], page_opts, filters_acc)
  end

  defp intents_filter(%{tag_ids: tag_ids} = page_opts, filters_acc) do
    intents_filter_next(:tag_ids, [tag_ids: tag_ids], page_opts, filters_acc)
  end

  defp intents_filter(%{at_location: at_location_id} = page_opts, filters_acc) do
    intents_filter_next(:at_location, [at_location_id: at_location_id], page_opts, filters_acc)
  end

  defp intents_filter(
         %{
           geolocation: %{
             near_point: %{lat: lat, long: long},
             distance: %{meters: distance_meters}
           }
         } = page_opts,
         filters_acc
       ) do
    IO.inspect(geo_with_point: page_opts)

    intents_filter_next(
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

  defp intents_filter(
         %{
           geolocation: %{near_address: address} = geolocation
         } = page_opts,
         filters_acc
       ) do
    IO.inspect(geo_with_address: page_opts)

    with {:ok, coords} <- Geocoder.call(address) do
      # IO.inspect(coords)

      intents_filter(
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
        intents_filter_next(
          :geolocation,
          [],
          page_opts,
          filters_acc
        )
    end
  end

  defp intents_filter(
         %{
           geolocation: geolocation
         } = page_opts,
         filters_acc
       ) do
    IO.inspect(geo_without_distance: page_opts)

    intents_filter(
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

  defp intents_filter(
         _,
         filters_acc
       ) do
    IO.inspect(filters_query: filters_acc)

    # finally, if there's no more known params to acumulate, query with the filters
    Intents.many(filters_acc)
  end

  defp intents_filter_next(param_remove, filter_add, page_opts, filters_acc)
       when is_list(param_remove) and is_list(filter_add) do
    IO.inspect(intents_filter_next: param_remove)
    IO.inspect(intents_filter_add: filter_add)

    intents_filter(Map.drop(page_opts, param_remove), filters_acc ++ filter_add)
  end

  defp intents_filter_next(param_remove, filter_add, page_opts, filters_acc)
       when not is_list(filter_add) do
    intents_filter_next(param_remove, [filter_add], page_opts, filters_acc)
  end

  defp intents_filter_next(param_remove, filter_add, page_opts, filters_acc)
       when not is_list(param_remove) do
    intents_filter_next([param_remove], filter_add, page_opts, filters_acc)
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

  def fetch_intent(info, id) do
    Intents.one([
      :default,
      user: GraphQL.current_user(info),
      id: id
      # preload: :tags
    ])
  end

  def creator_intents_edge(%{creator: creator}, %{} = page_opts, info) do
    ResolvePages.run(%ResolvePages{
      module: __MODULE__,
      fetcher: :fetch_creator_intents_edge,
      context: creator,
      page_opts: page_opts,
      info: info
    })
  end

  def fetch_creator_intents_edge(page_opts, info, ids) do
    list_intents(
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

  def list_intents(page_opts, base_filters, _data_filters, _cursor_type) do
    FetchPage.run(%FetchPage{
      queries: Queries,
      query: Intent,
      # cursor_fn: Intents.cursor(cursor_type),
      page_opts: page_opts,
      base_filters: base_filters
      # data_filters: data_filters
    })
  end

  def fetch_intents(page_opts, info) do
    FetchPage.run(%FetchPage{
      queries: ValueFlows.Planning.Intent.Queries,
      query: ValueFlows.Planning.Intent,
      # preload: [:provider, :receiver, :tags],
      # cursor_fn: Intents.cursor(:followers),
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
      queries: ValueFlows.Planning.Intent.Queries,
      query: ValueFlows.Planning.Intent,
      page_opts: page_opts,
      base_filters: [
        [:default, :offer],
        user: GraphQL.current_user(info)
      ]
    })
  end

  def fetch_needs(page_opts, info) do
    FetchPage.run(%FetchPage{
      queries: ValueFlows.Planning.Intent.Queries,
      query: ValueFlows.Planning.Intent,
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
    thing = Repo.preload(thing, tags: :character)
    urls = Enum.map(thing.tags, & &1.character.actor.canonical_url)
    {:ok, urls}
  end

  def create_offer(%{intent: intent_attrs}, info) do
    with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info) do
      create_intent(
        %{intent: Map.put(intent_attrs, :provider, user.id)},
        info
      )
    end
  end

  def create_need(%{intent: intent_attrs}, info) do
    with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info) do
      create_intent(
        %{intent: Map.put(intent_attrs, :receiver, user.id)},
        info
      )
    end
  end

  def create_intent(%{intent: %{in_scope_of: context_ids} = intent_attrs}, info)
      when is_list(context_ids) do
    # FIXME: support multiple contexts?
    context_id = List.first(context_ids)

    create_intent(
      %{intent: Map.merge(intent_attrs, %{in_scope_of: context_id})},
      info
    )
  end

  def create_intent(%{intent: %{in_scope_of: context_id, action: action_id} = intent_attrs}, info)
      when not is_nil(context_id) do
    # FIXME, need to do something like validate_thread_context to validate the provider/receiver agent ID
    Repo.transact_with(fn ->
      with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info),
           {:ok, action} <- Actions.action(action_id),
           {:ok, pointer} <- Pointers.one(id: context_id),
           context = Pointers.follow!(pointer),
           {:ok, uploads} <- UploadResolver.upload(user, intent_attrs, info),
           intent_attrs = Map.merge(intent_attrs, uploads),
           intent_attrs = Map.merge(intent_attrs, %{is_public: true}),
           {:ok, intent} <- Intents.create(user, action, context, intent_attrs) do
        {:ok, %{intent: %{intent | action: action}}}
      end
    end)
  end

  # FIXME: duplication!
  def create_intent(%{intent: %{action: action_id} = intent_attrs}, info) do
    Repo.transact_with(fn ->
      with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info),
           {:ok, action} <- Actions.action(action_id),
           {:ok, uploads} <- UploadResolver.upload(user, intent_attrs, info),
           intent_attrs = Map.merge(intent_attrs, uploads),
           intent_attrs = Map.merge(intent_attrs, %{is_public: true}),
           {:ok, intent} <- Intents.create(user, action, intent_attrs) do
        {:ok, %{intent: %{intent | action: action}}}
      end
    end)
  end

  def update_intent(%{intent: %{in_scope_of: context_ids} = changes}, info) do
    context_id = List.first(context_ids)

    Repo.transact_with(fn ->
      do_update(changes, info, fn intent, changes ->
        with {:ok, pointer} <- Pointers.one(id: context_id) do
          context = Pointers.follow!(pointer)
          Intents.update(intent, context, changes)
        end
      end)
    end)
  end

  def update_intent(%{intent: changes}, info) do
    Repo.transact_with(fn ->
      do_update(changes, info, fn intent, changes ->
        Intents.update(intent, changes)
      end)
    end)
  end

  defp do_update(%{id: id} = changes, info, update_fn) do
    with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info),
         {:ok, intent} <- intent(%{id: id}, info),
         :ok <- ensure_update_permission(user, intent),
         {:ok, uploads} <- UploadResolver.upload(user, changes, info),
         changes = Map.merge(changes, uploads),
         {:ok, intent} <- update_fn.(intent, changes) do
      {:ok, %{intent: intent}}
    end
  end

  def delete_intent(%{id: id}, info) do
    Repo.transact_with(fn ->
      with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info),
           {:ok, intent} <- intent(%{id: id}, info),
           :ok <- ensure_update_permission(user, intent),
           {:ok, _} <- Intents.soft_delete(intent) do
        {:ok, true}
      end
    end)
  end

  def ensure_update_permission(user, intent) do
    if user.local_user.is_instance_admin or intent.creator_id == user.id do
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
  #   # Keyword.fetch!(CommonsPub.Config.get(Threads), :valid_contexts)
  # end
end
