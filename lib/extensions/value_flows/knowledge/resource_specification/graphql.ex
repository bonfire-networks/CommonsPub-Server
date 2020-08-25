# SPDX-License-Identifier: AGPL-3.0-only
defmodule ValueFlows.Knowledge.ResourceSpecification.GraphQL do
  use Absinthe.Schema.Notation

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

  alias ValueFlows.Knowledge.ResourceSpecification
  alias ValueFlows.Knowledge.ResourceSpecification.ResourceSpecifications
  alias ValueFlows.Knowledge.ResourceSpecification.Queries
  alias ValueFlows.Knowledge.Action.Actions
  # alias MoodleNetWeb.GraphQL.CommonResolver
  alias MoodleNetWeb.GraphQL.UploadResolver

  # SDL schema import
  # import_sdl path: "lib/value_flows/graphql/schemas/planning.gql"

  # TODO: put in config
  # @tags_seperator " "

  ## resolvers

  def simulate(%{id: id}, _) do
    {:ok, ValueFlows.Simulate.resource_specification()}
  end

  def simulate(_, _) do
    {:ok, CommonsPub.Utils.Trendy.some(1..5, &ValueFlows.Simulate.resource_specification/0)}
  end

  def respec(%{id: id}, info) do
    ResolveField.run(%ResolveField{
      module: __MODULE__,
      fetcher: :fetch_respec,
      context: id,
      info: info
    })
  end

  def respecs(page_opts, info) do
    ResolveRootPage.run(%ResolveRootPage{
      module: __MODULE__,
      fetcher: :fetch_respecs,
      page_opts: page_opts,
      info: info,
      # popularity
      cursor_validators: [&(is_integer(&1) and &1 >= 0), &Ecto.ULID.cast/1]
    })
  end

  def all_respecs(_, _) do
    ResourceSpecifications.many()
  end

  def respecs_filtered(page_opts, _) do
    IO.inspect(respecs_filtered: page_opts)
    respecs_filter(page_opts, [])
  end

  # def respecs_filtered(page_opts, _) do
  #   IO.inspect(unhandled_filtering: page_opts)
  #   all_respecs(page_opts, nil)
  # end

  # TODO: support several filters combined, plus pagination on filtered queries

  defp respecs_filter(%{agent: id} = page_opts, filters_acc) do
    respecs_filter_next(:agent, [agent_id: id], page_opts, filters_acc)
  end

  defp respecs_filter(%{in_scope_of: context_id} = page_opts, filters_acc) do
    respecs_filter_next(:in_scope_of, [context_id: context_id], page_opts, filters_acc)
  end

  defp respecs_filter(
         _,
         filters_acc
       ) do
    IO.inspect(filters_query: filters_acc)

    # finally, if there's no more known params to acumulate, query with the filters
    ResourceSpecifications.many(filters_acc)
  end

  defp respecs_filter_next(param_remove, filter_add, page_opts, filters_acc)
       when is_list(param_remove) and is_list(filter_add) do
    IO.inspect(respecs_filter_next: param_remove)
    IO.inspect(respecs_filter_add: filter_add)

    respecs_filter(Map.drop(page_opts, param_remove), filters_acc ++ filter_add)
  end

  defp respecs_filter_next(param_remove, filter_add, page_opts, filters_acc)
       when not is_list(filter_add) do
    respecs_filter_next(param_remove, [filter_add], page_opts, filters_acc)
  end

  defp respecs_filter_next(param_remove, filter_add, page_opts, filters_acc)
       when not is_list(param_remove) do
    respecs_filter_next([param_remove], filter_add, page_opts, filters_acc)
  end

  ## fetchers

  def fetch_respec(info, id) do
    ResourceSpecifications.one([
      :default,
      user: GraphQL.current_user(info),
      id: id
      # preload: :tags
    ])
  end

  def creator_respecs_edge(%{creator: creator}, %{} = page_opts, info) do
    ResolvePages.run(%ResolvePages{
      module: __MODULE__,
      fetcher: :fetch_creator_respecs_edge,
      context: creator,
      page_opts: page_opts,
      info: info
    })
  end

  def fetch_creator_respecs_edge(page_opts, info, ids) do
    list_respecs(
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

  def list_respecs(page_opts, base_filters, _data_filters, _cursor_type) do
    FetchPage.run(%FetchPage{
      queries: Queries,
      query: ResourceSpecification,
      # cursor_fn: ResourceSpecifications.cursor(cursor_type),
      page_opts: page_opts,
      base_filters: base_filters
      # data_filters: data_filters
    })
  end

  def fetch_respecs(page_opts, info) do
    FetchPage.run(%FetchPage{
      queries: ValueFlows.Knowledge.ResourceSpecification.Queries,
      query: ValueFlows.Knowledge.ResourceSpecification,
      # preload: [:primary_accountable, :receiver, :tags],
      # cursor_fn: ResourceSpecifications.cursor(:followers),
      page_opts: page_opts,
      base_filters: [
        :default,
        # preload: [:primary_accountable, :receiver, :tags],
        user: GraphQL.current_user(info)
      ]
      # data_filters: [page: [desc: [followers: page_opts]]],
    })
  end

  def fetch_classifications_edge(%{tags: _tags} = thing, _, _) do
    thing = Repo.preload(thing, tags: [character: [:actor]])
    urls = Enum.map(thing.tags, & &1.character.actor.canonical_url)
    {:ok, urls}
  end

  def create_respec(%{respec: %{in_scope_of: context_ids} = respec_attrs}, info)
      when is_list(context_ids) do
    # FIXME: support multiple contexts?
    context_id = List.first(context_ids)

    create_respec(
      %{respec: Map.merge(respec_attrs, %{in_scope_of: context_id})},
      info
    )
  end

  def create_respec(
        %{respec: %{in_scope_of: context_id, state: state_id} = respec_attrs},
        info
      )
      when not is_nil(context_id) do
    # FIXME, need to do something like validate_thread_context to validate the primary_accountable/receiver agent ID
    Repo.transact_with(fn ->
      with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info),
           {:ok, state} <- Actions.action(state_id),
           {:ok, pointer} <- Pointers.one(id: context_id),
           context = Pointers.follow!(pointer),
           {:ok, uploads} <- UploadResolver.upload(user, respec_attrs, info),
           respec_attrs = Map.merge(respec_attrs, uploads),
           respec_attrs = Map.merge(respec_attrs, %{is_public: true}),
           {:ok, respec} <- ResourceSpecifications.create(user, state, context, respec_attrs) do
        {:ok, %{respec: %{respec | state: state}}}
      end
    end)
  end

  # FIXME: duplication!
  def create_respec(%{respec: %{state: state_id} = respec_attrs}, info) do
    Repo.transact_with(fn ->
      with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info),
           {:ok, state} <- Actions.action(state_id),
           {:ok, uploads} <- UploadResolver.upload(user, respec_attrs, info),
           respec_attrs = Map.merge(respec_attrs, uploads),
           respec_attrs = Map.merge(respec_attrs, %{is_public: true}),
           {:ok, respec} <- ResourceSpecifications.create(user, state, respec_attrs) do
        {:ok, %{respec: %{respec | state: state}}}
      end
    end)
  end

  def update_respec(%{respec: %{in_scope_of: context_ids} = changes}, info) do
    context_id = List.first(context_ids)

    Repo.transact_with(fn ->
      do_update(changes, info, fn respec, changes ->
        with {:ok, pointer} <- Pointers.one(id: context_id) do
          context = Pointers.follow!(pointer)
          ResourceSpecifications.update(respec, context, changes)
        end
      end)
    end)
  end

  def update_respec(%{respec: changes}, info) do
    Repo.transact_with(fn ->
      do_update(changes, info, fn respec, changes ->
        ResourceSpecifications.update(respec, changes)
      end)
    end)
  end

  defp do_update(%{id: id} = changes, info, update_fn) do
    with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info),
         {:ok, respec} <- respec(%{id: id}, info),
         :ok <- ensure_update_permission(user, respec),
         {:ok, uploads} <- UploadResolver.upload(user, changes, info),
         changes = Map.merge(changes, uploads),
         {:ok, respec} <- update_fn.(respec, changes) do
      {:ok, %{respec: respec}}
    end
  end

  def delete_respec(%{id: id}, info) do
    Repo.transact_with(fn ->
      with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info),
           {:ok, respec} <- respec(%{id: id}, info),
           :ok <- ensure_update_permission(user, respec),
           {:ok, _} <- ResourceSpecifications.soft_delete(respec) do
        {:ok, true}
      end
    end)
  end

  def ensure_update_permission(user, respec) do
    if user.local_user.is_instance_admin or respec.creator_id == user.id do
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
