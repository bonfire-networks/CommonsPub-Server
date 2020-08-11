# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule ValueFlows.Proposal.GraphQL do

  use Absinthe.Schema.Notation
  alias MoodleNetWeb.GraphQL.{CommonResolver}
  require Logger
  import ValueFlows.Util, only: [maybe_put: 3]
  alias MoodleNet.{
    Activities,
    Communities,
    GraphQL,
    Repo,
    User
  }

  alias MoodleNet.GraphQL.{
    ResolveField,
    ResolveFields,
    ResolvePage,
    ResolvePages,
    ResolveRootPage,
    FetchPage,
    FetchPages,
    CommonResolver
  }

  # alias MoodleNet.Resources.Resource
  alias MoodleNet.Common.Enums
  alias MoodleNet.Meta.Pointers
  alias MoodleNet.Communities.Community
  alias MoodleNetWeb.GraphQL.CommunitiesResolver

  alias ValueFlows.Proposal.Proposal
  alias ValueFlows.Proposal.Proposals
  alias ValueFlows.Proposal.Queries
  alias MoodleNetWeb.GraphQL.{CommonResolver}


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

  def all_proposals(page_opts, info) do
    Proposals.many()
  end

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
      queries: ValueFlows.Planning.Proposal.Queries,
      query: ValueFlows.Planning.Proposal,
      page_opts: page_opts,
      base_filters: [
        :default,
        # preload: [:provider, :receiver, :tags],
        user: GraphQL.current_user(info)
      ]
      # data_filters: [page: [desc: [followers: page_opts]]],
    })
  end


  def create_proposal(%{proposal: %{in_scope_of: context_ids} = proposal_attrs}, info)
      when is_list(context_ids) do
    # FIXME: support multiple contexts?
    context_id = List.first(context_ids)

    create_proposal(
      %{proposal: Map.merge(proposal_attrs, %{in_scope_of: context_id})},
      info
    )
  end

  # FIXME: duplication!
  def create_proposal(%{proposal: proposal_attrs}, info) do
    Repo.transact_with(fn ->
      with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info),
           proposal_attrs = Map.merge(proposal_attrs, %{is_public: true}),
           {:ok, proposal} <- Proposals.create(user, proposal_attrs) do
        {:ok, %{proposal: proposal}}
      end
    end)
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

  defp validate_agent(pointer) do
    if Pointers.table!(pointer).schema in valid_contexts() do
      :ok
    else
      GraphQL.not_permitted()
    end
  end

  defp valid_contexts() do
    [User, Community, Organisation]
    # Keyword.fetch!(Application.get_env(:moodle_net, Threads), :valid_contexts)
  end


end
