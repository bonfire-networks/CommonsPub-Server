# SPDX-License-Identifier: AGPL-3.0-only
defmodule ValueFlows.Planning.Intent.GraphQL do
  use Absinthe.Schema.Notation
  require Logger

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

  alias MoodleNetWeb.GraphQL.{CommonResolver}

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

  def all_intents(page_opts, info) do
    ResolveRootPage.run(%ResolveRootPage{
      module: __MODULE__,
      fetcher: :fetch_intents,
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
      id: id,
      preload: :tags
    ])
  end

  def fetch_intents(page_opts, info) do
    FetchPage.run(%FetchPage{
      queries: Queries,
      query: Intent,
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

  def fetch_provider_edge(%{provider: id}, _, info) do
    # IO.inspect(id)
    # Repo.preload(team_users: :user)
    CommonResolver.context_edge(%{context_id: id}, nil, info)
  end

  def fetch_receiver_edge(%{receiver: id}, _, info) do
    CommonResolver.context_edge(%{context_id: id}, nil, info)
  end

  def fetch_classifications_edge(%{tags: tags} = data, _, _) do
    data = Repo.preload(data, tags: [character: [:actor]])
    # IO.inspect(get_tags: data.tags)
    urls = Enum.map(data.tags, & &1.character.actor.canonical_url)
    # IO.inspect(urls)
    {:ok, urls}
  end

  ## finally the mutations...

  @measure_fields [:resource_quantity, :effort_quantity, :available_quantity]

  def create_intent(%{intent: %{in_scope_of: context_ids} = intent_attrs}, info)
      when is_list(context_ids) do
    # FIXME: support multiple contexts?
    context_id = List.first(context_ids)

    create_intent(
      %{intent: Map.merge(intent_attrs, %{in_scope_of: context_id})},
      info
    )
  end

  def create_intent(%{intent: %{in_scope_of: context_id} = intent_attrs}, info)
      when not is_nil(context_id) do
    # FIXME, need to do something like validate_thread_context to validate the provider/receiver agent ID
    Repo.transact_with(fn ->
      with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info),
           {:ok, pointer} <- Pointers.one(id: context_id),
           context = Pointers.follow!(pointer),
           {:ok, measures} <-
             Measurement.Measure.GraphQL.create_measures(intent_attrs, info, @measure_fields),
           intent_attrs = Map.merge(intent_attrs, %{is_public: true}),
           {:ok, intent} <- Intents.create(user, context, measures, intent_attrs),
           {:ok, intent} <- try_tag_intent(user, intent, intent_attrs) do
        {:ok, %{intent: intent}}
      end
    end)
  end

  # FIXME: duplication!
  def create_intent(%{intent: intent_attrs}, info) do
    Repo.transact_with(fn ->
      with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info),
           {:ok, measures} <-
             Measurement.Measure.GraphQL.create_measures(intent_attrs, info, @measure_fields),
           intent_attrs = Map.merge(intent_attrs, %{is_public: true}),
           {:ok, intent} <- Intents.create(user, measures, intent_attrs),
           {:ok, intent} <- try_tag_intent(user, intent, intent_attrs) do
        {:ok, %{intent: intent}}
      end
    end)
  end

  @doc """
  lookup tag from URL(s), to support vf-graphql mode
  """
  def try_tag_intent(user, intent, %{resourceClassifiedAs: urls = intent_attrs})
      when is_list(urls) and length(urls) > 0 do
    # todo: lookup tag by URL
    {:ok, intent}
  end

  @doc """
  tag IDs from a `tags` field
  """
  def try_tag_intent(user, intent, %{tags: text} = intent_attrs) when bit_size(text) > 1 do
    tag_ids = MoodleNetWeb.Component.TagAutocomplete.tags_split(text)
    {:ok, intent_tags(user, intent, tag_ids)}
  end

  @doc """
  otherwise maybe we have tagnames inline in the note?
  """
  def try_tag_intent(user, intent, %{note: text} = intent_attrs) when bit_size(text) > 1 do
    # MoodleNetWeb.Component.TagAutocomplete.try_prefixes(text)
    # TODO
    {:ok, intent}
  end

  def try_tag_intent(user, intent, _) do
    {:ok, intent}
  end

  @doc """
  tag existing intent with a Taggable, Pointer, or anything that can be made taggable
  """
  def intent_tag(user, intent, taggable) do
    Tag.TagThings.tag_thing(user, taggable, intent)
  end

  @doc """
  tag existing intent with one or multiple Taggables, Pointers, or anything that can be made taggable
  """
  def intent_tags(user, intent, taggables) do
    intent_tags = Enum.map(taggables, &intent_tag(user, intent, &1))
    intent |> Map.merge(%{tags: intent_tags})
  end

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

  defp do_update(%{id: id} = changes, info, update_fn) do
    with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info),
         {:ok, intent} <- intent(%{id: id}, info),
         :ok <- ensure_update_permission(user, intent),
         {:ok, measures} <-
           Measurement.Measure.GraphQL.update_measures(changes, info, @measure_fields),
         {:ok, intent} <- update_fn.(intent, measures) do
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
