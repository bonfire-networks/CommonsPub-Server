# SPDX-License-Identifier: AGPL-3.0-only
defmodule CommonsPub.Character.GraphQL.Resolver do
  alias MoodleNet.{
    Activities,
    GraphQL,
    Repo,
    Resources
  }

  alias MoodleNet.GraphQL.{
    # Flow,
    FetchFields,
    FetchPage,
    # FetchPages,
    ResolveField,
    ResolvePage,
    # ResolvePages,
    ResolveRootPage
  }

  alias CommonsPub.Character

  alias CommonsPub.Character.{
    Characters
    # Queries
  }

  alias MoodleNet.Resources.Resource
  # alias MoodleNet.Common.Enums
  alias Pointers

  ## resolvers

  def character(%{character: character}, _, _info) do
    {:ok, Repo.preload(character, :actor)}
  end

  def character(%{character_id: id}, _, info) do
    character(%{character_id: id}, info)
  end

  def character(%{character_id: id}, info) do
    # IO.inspect(id)
    ResolveField.run(%ResolveField{
      module: __MODULE__,
      fetcher: :fetch_character,
      context: id,
      info: info
    })
  end

  def characters(page_opts, info) do
    ResolveRootPage.run(%ResolveRootPage{
      module: __MODULE__,
      fetcher: :fetch_characters,
      page_opts: page_opts,
      info: info,
      # popularity
      cursor_validators: [&(is_integer(&1) and &1 >= 0), &Ecto.ULID.cast/1]
    })
  end

  ## fetchers

  def fetch_character(info, id) do
    Characters.one(
      user: GraphQL.current_user(info),
      id: id,
      preload: :actor
    )
  end

  def fetch_characters(page_opts, info) do
    FetchPage.run(%FetchPage{
      queries: CommonsPub.Character.Queries,
      query: CommonsPub.Character,
      cursor_fn: Characters.cursor(:followers),
      page_opts: page_opts,
      base_filters: [user: GraphQL.current_user(info)],
      data_filters: [page: [desc: [followers: page_opts]]]
    })
  end

  # def characteristic_edge(%CommonsPub.Character{characteristic_id: id}, _, info), do: MoodleNetWeb.GraphQL.CommonResolver.context_edge(%{context_id: id}, nil, info)

  # def resource_count_edge(%CommonsPub.Character{id: id}, _, info) do
  #   Flow.fields(__MODULE__, :fetch_resource_count_edge, id, info, default: 0)
  # end

  def fetch_resource_count_edge(_, ids) do
    FetchFields.run(%FetchFields{
      queries: Resources.Queries,
      query: Resource,
      group_fn: &elem(&1, 0),
      map_fn: &elem(&1, 1),
      filters: [character_id: ids, group_count: :character_id]
    })
  end

  def last_activity_edge(_, _, _info) do
    {:ok, DateTime.utc_now()}
  end

  def outbox_edge(%{outbox_id: id}, page_opts, info) do
    with :ok <- GraphQL.not_in_list_or_empty_page(info) do
      ResolvePage.run(%ResolvePage{
        module: __MODULE__,
        fetcher: :fetch_outbox_edge,
        context: id,
        page_opts: page_opts,
        info: info
      })
    end
  end

  def fetch_outbox_edge(page_opts, _info, id) do
    tables = default_outbox_query_contexts()

    FetchPage.run(%FetchPage{
      queries: Activities.Queries,
      query: Activities.Activity,
      page_opts: page_opts,
      base_filters: [deleted: false, feed_timeline: id, table: tables],
      data_filters: [page: [desc: [created: page_opts]], preload: :context]
    })
  end

  defp default_outbox_query_contexts() do
    Application.fetch_env!(:moodle_net, CommonsPub.Character)
    |> Keyword.fetch!(:default_outbox_query_contexts)
  end

  ## finally the mutations...

  def create_character(%{character: attrs}, info) do
    Repo.transact_with(fn ->
      with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info) do
        attrs = Map.merge(attrs, %{is_public: true})
        Characters.create(user, attrs)
      end
    end)
  end

  def characterise(%{context_id: id}, info) do
    Repo.transact_with(fn ->
      with {:ok, me} <- GraphQL.current_user_or_not_logged_in(info),
           {:ok, pointer} <- MoodleNet.Meta.Pointers.one(id: id) do
        Characters.characterise(me, pointer)
      end
    end)
  end

  def update_character(%{character: changes, character_id: id}, info) do
    Repo.transact_with(fn ->
      with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info),
           {:ok, character} <- character(%{character_id: id}, info) do
        cond do
          user.local_user.is_instance_admin ->
            Characters.update(user, character, changes)

          character.creator_id == user.id ->
            Characters.update(user, character, changes)

          true ->
            GraphQL.not_permitted("update")
        end
      end
    end)
  end

  # def delete(%{character_id: id}, info) do
  #   # Repo.transact_with(fn ->
  #   #   with {:ok, user} <- GraphQL.current_user(info),
  #   #        {:ok, actor} <- Users.fetch_actor(user),
  #   #        {:ok, character} <- Characters.fetch(id) do
  #   #     character = Repo.preload(character, :community)
  #   # 	permitted =
  #   # 	  user.is_instance_admin or
  #   #       character.creator_id == actor.id or
  #   #       character.community.creator_id == actor.id
  #   # 	if permitted do
  #   # 	  with {:ok, _} <- Characters.soft_delete(character), do: {:ok, true}
  #   # 	else
  #   # 	  GraphQL.not_permitted()
  #   #     end
  #   #   end
  #   # end)
  #   # |> GraphQL.response(info)
  #   {:ok, true}
  #   |> GraphQL.response(info)
  # end

  # defp validate_character_context(pointer) do
  #   if Pointers.table!(pointer).schema in valid_contexts() do
  #     :ok
  #   else
  #     GraphQL.not_permitted()
  #   end
  # end

  # defp valid_contexts do
  #   Keyword.fetch!(Application.get_env(:moodle_net, Characters), :valid_contexts)
  # end

  # def creator_edge(%{character: %{creator_id: id}}, _, info) do
  #   ActorsResolver.creator_edge(%{creator_id: id}, nil, info)
  # end
end
