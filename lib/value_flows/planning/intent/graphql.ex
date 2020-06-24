# SPDX-License-Identifier: AGPL-3.0-only
defmodule ValueFlows.Planning.Intent.GraphQL do
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
    CommonResolver,
  }
  # alias MoodleNet.Resources.Resource
  alias MoodleNet.Common.Enums
  alias MoodleNet.Meta.Pointers
  alias MoodleNetWeb.GraphQL.CommunitiesResolver

  alias ValueFlows.Planning.Intent
  alias ValueFlows.Planning.Intent.Intents
  alias ValueFlows.Planning.Intent.Queries

  # SDL schema import

  use Absinthe.Schema.Notation
  alias MoodleNetWeb.GraphQL.{CommonResolver}
  require Logger

  # import_sdl path: "lib/value_flows/graphql/schemas/planning.gql"

  ## resolvers

  def intent(%{id: id}, info) do
    ResolveField.run(
      %ResolveField{
        module: __MODULE__,
        fetcher: :fetch_intent,
        context: id,
        info: info,
      }
    )
  end

  def all_intents(page_opts, info) do
    ResolveRootPage.run(
      %ResolveRootPage{
        module: __MODULE__,
        fetcher: :fetch_intents,
        page_opts: page_opts,
        info: info,
        cursor_validators: [&(is_integer(&1) and &1 >= 0), &Ecto.ULID.cast/1], # popularity
      }
    )
  end

  ## fetchers

  def fetch_intent(info, id) do
    Intents.one(
      user: GraphQL.current_user(info),
      id: id,
    )
  end

  def fetch_intents(page_opts, info) do
    FetchPage.run(
      %FetchPage{
        queries: Queries,
        query: Intent,
        # preload: :provider,
        # cursor_fn: Intents.cursor(:followers),
        page_opts: page_opts,
        base_filters: [user: GraphQL.current_user(info)],
        # data_filters: [page: [desc: [followers: page_opts]]],
      }
    )
  end


  def fetch_provider_edge(%{provider: id}, _, info) do
    # IO.inspect(id)
    # Repo.preload(team_users: :user)
    CommonResolver.context_edge(%{context_id: id}, nil, info)
  end

  def fetch_receiver_edge(%{receiver: id}, _, info) do
    CommonResolver.context_edge(%{context_id: id}, nil, info)
  end


  ## finally the mutations...

  @measure_fields [:resource_quantity, :effort_quantity, :available_quantity]

  def create_intent(%{intent: %{in_scope_of: context_ids} = attrs}, info) when is_list(context_ids) do
    context_id = List.first(context_ids)
    # FIXME, need to do something like validate_thread_context to validate the provider/receiver agent ID
    Repo.transact_with(fn ->
      with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info),
           {:ok, pointer} <- Pointers.one(id: context_id),
           context = Pointers.follow!(pointer),
           {:ok, measures} <- Measurement.Measure.GraphQL.create_measures(attrs, info, @measure_fields),
           attrs = Map.merge(attrs, %{is_public: true}),
           {:ok, intent} <- Intents.create(user, context, measures, attrs) do
        {:ok, %{intent: intent}}
      end
    end)
  end

  def create_intent(%{intent: attrs}, info) do
    Repo.transact_with(fn ->
      with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info),
           {:ok, measures} <- Measurement.Measure.GraphQL.create_measures(attrs, info, @measure_fields),
           attrs = Map.merge(attrs, %{is_public: true}),
           {:ok, intent} <- Intents.create(user, measures, attrs) do
        {:ok, %{intent: intent}}
      end
    end)
  end

  # FIXME: duplication!
  def update_intent(%{intent: %{in_scope_of: context_ids} = changes}, info) do
    context_id = List.first(context_ids)

    Repo.transact_with(fn ->
      do_update(changes, info, fn intent, measures ->
        with {:ok, pointer} <- Pointers.one(id: context_id) do
          context = Pointers.follow!(pointer)
          Intents.update(intent, context, measures, changes)
        end
      end)
    end)
  end

  def update_intent(%{intent: changes}, info) do
    Repo.transact_with(fn ->
      do_update(changes, info, fn intent, measures ->
        Intents.update(intent, measures, changes)
      end)
    end)
  end

  def do_update(%{id: id} = changes, info, update_fn) do
    with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info),
         {:ok, intent} <- intent(%{id: id}, info),
         :ok <- ensure_update_permission(user, intent),
         {:ok, measures} <- Measurement.Measure.GraphQL.update_measures(changes, info, @measure_fields),
         {:ok, intent} <- update_fn.(intent, measures) do
      {:ok, %{intent: intent}}
    end
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
    [User, Organisation]
    # Keyword.fetch!(Application.get_env(:moodle_net, Threads), :valid_contexts)
  end

end
