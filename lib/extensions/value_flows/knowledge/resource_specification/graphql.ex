# SPDX-License-Identifier: AGPL-3.0-only
defmodule ValueFlows.Knowledge.ResourceSpecification.GraphQL do

  require Logger


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

  alias ValueFlows.Knowledge.ResourceSpecification
  alias ValueFlows.Knowledge.ResourceSpecification.ResourceSpecifications
  alias ValueFlows.Knowledge.ResourceSpecification.Queries
  # alias ValueFlows.Knowledge.Action.Actions
  # alias CommonsPub.Web.GraphQL.CommonResolver
  alias CommonsPub.Web.GraphQL.UploadResolver

  # SDL schema import
  #  use Absinthe.Schema.Notation
 # import_sdl path: "lib/value_flows/graphql/schemas/planning.gql"


  ## resolvers

  def simulate(%{id: _id}, _) do
    {:ok, ValueFlows.Simulate.resource_specification()}
  end

  def simulate(_, _) do
    {:ok, CommonsPub.Utils.Trendy.some(1..5, &ValueFlows.Simulate.resource_specification/0)}
  end

  def resource_spec(%{id: id}, info) do
    ResolveField.run(%ResolveField{
      module: __MODULE__,
      fetcher: :fetch_resource_spec,
      context: id,
      info: info
    })
  end

  def resource_specs(page_opts, info) do
    ResolveRootPage.run(%ResolveRootPage{
      module: __MODULE__,
      fetcher: :fetch_resource_specs,
      page_opts: page_opts,
      info: info,
      # popularity
      cursor_validators: [&(is_integer(&1) and &1 >= 0), &Ecto.ULID.cast/1]
    })
  end

  def all_resource_specs(_, _) do
    ResourceSpecifications.many([
      :default,
    ])
  end

  def resource_specs_filtered(page_opts, _) do
    resource_specs_filter(page_opts, [])
  end

  # def resource_specs_filtered(page_opts, _) do
  #   IO.inspect(unhandled_filtering: page_opts)
  #   all_resource_specs(page_opts, nil)
  # end

  # TODO: support several filters combined, plus pagination on filtered queries

  defp resource_specs_filter(%{in_scope_of: context_id} = page_opts, filters_acc) do
    resource_specs_filter_next(:in_scope_of, [context_id: context_id], page_opts, filters_acc)
  end

  defp resource_specs_filter(%{tag_ids: tag_ids} = page_opts, filters_acc) do
    resource_specs_filter_next(:tag_ids, [tag_ids: tag_ids], page_opts, filters_acc)
  end

  defp resource_specs_filter(
         _,
         filters_acc
       ) do

    # finally, if there's no more known params to acumulate, query with the filters
    ResourceSpecifications.many(filters_acc)
  end

  defp resource_specs_filter_next(param_remove, filter_add, page_opts, filters_acc)
       when is_list(param_remove) and is_list(filter_add) do
    resource_specs_filter(Map.drop(page_opts, param_remove), filters_acc ++ filter_add)
  end

  defp resource_specs_filter_next(param_remove, filter_add, page_opts, filters_acc)
       when not is_list(filter_add) do
    resource_specs_filter_next(param_remove, [filter_add], page_opts, filters_acc)
  end

  defp resource_specs_filter_next(param_remove, filter_add, page_opts, filters_acc)
       when not is_list(param_remove) do
    resource_specs_filter_next([param_remove], filter_add, page_opts, filters_acc)
  end

  ## fetchers

  def fetch_resource_spec(info, id) do
    ResourceSpecifications.one([
      :default,
      user: GraphQL.current_user(info),
      id: id,
    ])
  end

  def creator_resource_specs_edge(%{creator: creator}, %{} = page_opts, info) do
    ResolvePages.run(%ResolvePages{
      module: __MODULE__,
      fetcher: :fetch_creator_resource_specs_edge,
      context: creator,
      page_opts: page_opts,
      info: info
    })
  end

  def fetch_creator_resource_specs_edge(page_opts, info, ids) do
    list_resource_specs(
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

  def list_resource_specs(page_opts, base_filters, _data_filters, _cursor_type) do
    FetchPage.run(%FetchPage{
      queries: Queries,
      query: ResourceSpecification,
      # cursor_fn: ResourceSpecifications.cursor(cursor_type),
      page_opts: page_opts,
      base_filters: base_filters
      # data_filters: data_filters
    })
  end

  def fetch_resource_specs(page_opts, info) do
    FetchPage.run(%FetchPage{
      queries: ValueFlows.Knowledge.ResourceSpecification.Queries,
      query: ValueFlows.Knowledge.ResourceSpecification,
      # preload: [:tags],
      # cursor_fn: ResourceSpecifications.cursor(:followers),
      page_opts: page_opts,
      base_filters: [
        :default,
        # preload: [:tags],
        user: GraphQL.current_user(info)
      ]
      # data_filters: [page: [desc: [followers: page_opts]]],
    })
  end

  # FIXME: duplication!
  def create_resource_spec(%{resource_specification: resource_spec_attrs}, info) do
    Repo.transact_with(fn ->
      with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info),
           {:ok, uploads} <- UploadResolver.upload(user, resource_spec_attrs, info),
           resource_spec_attrs = Map.merge(resource_spec_attrs, uploads),
           resource_spec_attrs = Map.merge(resource_spec_attrs, %{is_public: true}),
           {:ok, resource_spec} <- ResourceSpecifications.create(user, resource_spec_attrs) do
        {:ok, %{resource_specification: resource_spec}}
      end
    end)
  end

  def update_resource_spec(%{resource_specification: %{id: id} = changes}, info) do
    with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info),
         {:ok, resource_spec} <- resource_spec(%{id: id}, info),
         :ok <- ensure_update_permission(user, resource_spec),
         {:ok, uploads} <- UploadResolver.upload(user, changes, info),
         changes = Map.merge(changes, uploads),
         {:ok, resource_spec} <- ResourceSpecifications.update(resource_spec, changes) do
      {:ok, %{resource_specification: resource_spec}}
    end
  end

  def delete_resource_spec(%{id: id}, info) do
    Repo.transact_with(fn ->
      with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info),
           {:ok, resource_spec} <- resource_spec(%{id: id}, info),
           :ok <- ensure_update_permission(user, resource_spec),
           {:ok, _} <- ResourceSpecifications.soft_delete(resource_spec) do
        {:ok, true}
      end
    end)
  end

  def ensure_update_permission(user, resource_spec) do
    if user.local_user.is_instance_admin or resource_spec.creator_id == user.id do
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
