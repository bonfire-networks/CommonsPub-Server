# SPDX-License-Identifier: AGPL-3.0-only
defmodule ValueFlows.Planning.Intent.GraphQL do
  use Absinthe.Schema.Notation
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

  alias ValueFlows.Planning.Intent
  alias ValueFlows.Planning.Intent.Intents
  alias ValueFlows.Planning.Intent.Queries
  alias ValueFlows.Knowledge.Action.Actions
  alias MoodleNetWeb.GraphQL.{CommonResolver}
  alias MoodleNetWeb.GraphQL.UploadResolver

  # SDL schema import
  # import_sdl path: "lib/value_flows/graphql/schemas/planning.gql"

  # TODO: put in config
  @tags_seperator " "

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

  def all_intents(page_opts, info) do
    Intents.many()
  end

  # TODO: support several filters combined, plus pagination
  def intents_filter(%{at_location: at_location_id} = page_opts, info) do
    Intents.many(at_location_id: at_location_id)
  end

  def intents_filter(%{in_scope_of: context_id} = page_opts, info) do
    Intents.many(context_id: context_id)
  end

  def intents_filter(page_opts, info) do
    all_intents(page_opts, info)
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

  def fetch_provider_edge(%{provider_id: id}, _, info) do
    # Repo.preload(team_users: :user)
    CommonResolver.context_edge(%{context_id: id}, nil, info)
  end

  def fetch_receiver_edge(%{receiver_id: id}, _, info) do
    CommonResolver.context_edge(%{context_id: id}, nil, info)
  end

  def fetch_classifications_edge(%{tags: _tags} = thing, _, _) do
    thing = Repo.preload(thing, tags: [character: [:actor]])
    urls = Enum.map(thing.tags, & &1.character.actor.canonical_url)
    {:ok, urls}
  end

  def create_offer(%{intent: intent_attrs}, info) do
    # TODO: is it always the caller that's the provider?
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
