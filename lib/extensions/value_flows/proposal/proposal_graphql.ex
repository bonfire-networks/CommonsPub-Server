# SPDX-License-Identifier: AGPL-3.0-only
defmodule ValueFlows.Proposal.GraphQL do
  use Absinthe.Schema.Notation
  # alias CommonsPub.Web.GraphQL.{CommonResolver}
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
    # ResolvePages,
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

  # alias ValueFlows.Proposal
  alias ValueFlows.Proposal.Proposals
  # alias ValueFlows.Proposal.Queries
  # alias CommonsPub.Web.GraphQL.CommonResolver

  # import_sdl path: "lib/value_flows/graphql/schemas/proposal.gql"

  ## resolvers

  def proposal(%{id: id}, info) do
    ResolveField.run(%ResolveField{
      module: __MODULE__,
      fetcher: :fetch_proposal,
      context: id,
      info: info
    })
  end

  def proposals(page_opts, info) do
    ResolveRootPage.run(%ResolveRootPage{
      module: __MODULE__,
      fetcher: :fetch_proposals,
      page_opts: page_opts,
      info: info,
      # popularity
      cursor_validators: [&(is_integer(&1) and &1 >= 0), &Ecto.ULID.cast/1]
    })
  end

  def all_proposals(_page_opts, _info) do
    Proposals.many()
  end

  def eligible_location_edge(%{eligible_location_id: id} = proposal, _, _) when not is_nil(id) do
    proposal = Repo.preload(proposal, :eligible_location)
    location = proposal
    |> Map.get(:eligible_location, nil)
    |> Geolocation.Geolocations.populate_coordinates()
    {:ok, location}
  end

  def eligible_location_edge(_, _, _), do: {:ok, nil}

  ## fetchers

  def fetch_proposal(info, id) do
    Proposals.one([
      :default,
      user: GraphQL.current_user(info),
      id: id
      # preload: :tags
    ])
  end

  def fetch_proposals(page_opts, info) do
    FetchPage.run(%FetchPage{
      queries: ValueFlows.Proposal.Queries,
      query: ValueFlows.Proposal,
      page_opts: page_opts,
      base_filters: [
        :default,
        # preload: [:provider, :receiver, :tags],
        user: GraphQL.current_user(info)
      ]
      # data_filters: [page: [desc: [followers: page_opts]]],
    })
  end

  def create_proposal(%{proposal: %{in_scope_of: context_ids} = attrs}, info)
      when is_list(context_ids) do
    # FIXME: support multiple contexts?
    context_id = List.first(context_ids)

    Repo.transact_with(fn ->
      do_create(attrs, info, fn user, attrs ->
        with {:ok, pointer} <- Pointers.one(id: context_id) do
          context = Pointers.follow!(pointer)
          Proposals.create(user, context, attrs)
        end
      end)
    end)
  end

  # FIXME: duplication!
  def create_proposal(%{proposal: attrs}, info) do
    Repo.transact_with(fn ->
      do_create(attrs, info, &Proposals.create/2)
    end)
  end

  defp do_create(%{} = attrs, info, create_fn) do
    with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info),
         proposal_attrs = Map.merge(attrs, %{is_public: true}),
         {:ok, proposal} <- create_fn.(user, proposal_attrs) do
      {:ok, %{proposal: proposal}}
    end
  end

  def update_proposal(%{proposal: %{in_scope_of: context_ids} = changes}, info) do
    context_id = List.first(context_ids)

    Repo.transact_with(fn ->
      do_update(changes, info, fn proposal, changes ->
        with {:ok, pointer} <- Pointers.one(id: context_id) do
          context = Pointers.follow!(pointer)
          Proposals.update(proposal, context, changes)
        end
      end)
    end)
  end

  def update_proposal(%{proposal: changes}, info) do
    Repo.transact_with(fn ->
      do_update(changes, info, fn proposal, changes ->
        Proposals.update(proposal, changes)
      end)
    end)
  end

  defp do_update(%{id: id} = changes, info, update_fn) do
    with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info),
         {:ok, proposal} <- proposal(%{id: id}, info),
         :ok <- ensure_update_permission(user, proposal),
         {:ok, proposal} <- update_fn.(proposal, changes) do
      {:ok, %{proposal: proposal}}
    end
  end

  def delete_proposal(%{id: id}, info) do
    Repo.transact_with(fn ->
      with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info),
           {:ok, proposal} <- proposal(%{id: id}, info),
           :ok <- ensure_update_permission(user, proposal),
           {:ok, _} <- Proposals.soft_delete(proposal) do
        {:ok, true}
      end
    end)
  end

  def ensure_update_permission(user, proposal) do
    if user.local_user.is_instance_admin or proposal.creator_id == user.id do
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
