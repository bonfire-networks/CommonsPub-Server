# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule Character.GraphQL.Resolver do
  alias MoodleNet.{
    Activities,
    GraphQL,
    Repo,
    Resources,
  }
  alias MoodleNet.GraphQL.{
    CommonResolver,
    Flow,
    FetchFields,
    FetchPage,
    FetchPages,
    ResolveField,
    ResolvePage,
    ResolvePages,
    ResolveRootPage,
  }
  alias Character
  alias Character.{Characters, Queries}
  alias MoodleNet.Resources.Resource
  alias MoodleNet.Common.Enums
  alias MoodleNet.Meta.Pointers

  ## resolvers

  def character(%{character_id: id}, info) do
    # IO.inspect(id)
    ResolveField.run(
      %ResolveField{
        module: __MODULE__,
        fetcher: :fetch_character,
        context: id,
        info: info,
      }
    )
  end

  def character(%{character_id: id}, _, info) do
    character(%{character_id: id}, info)
  end

  def character(opts, _, info) do
    # IO.inspect(opts)
    {:ok, nil}
  end

  def characters(page_opts, info) do
    ResolveRootPage.run(
      %ResolveRootPage{
        module: __MODULE__,
        fetcher: :fetch_characters,
        page_opts: page_opts,
        info: info,
        cursor_validators: [&(is_integer(&1) and &1 >= 0), &Ecto.ULID.cast/1], # popularity
      }
    )
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
    FetchPage.run(
      %FetchPage{
        queries: Character.Queries,
        query: Character,
        cursor_fn: Characters.cursor(:followers),
        page_opts: page_opts,
        base_filters: [user: GraphQL.current_user(info)],
        data_filters: [page: [desc: [followers: page_opts]]],
      }
    )
  end

  def resource_count_edge(%Character{id: id}, _, info) do
    Flow.fields __MODULE__, :fetch_resource_count_edge, id, info, default: 0
  end

  def fetch_resource_count_edge(_, ids) do
    FetchFields.run(
      %FetchFields{
        queries: Resources.Queries,
        query: Resource,
        group_fn: &elem(&1, 0),
        map_fn: &elem(&1, 1),
        filters: [character_id: ids, group_count: :character_id],
      }
    )
  end

  def last_activity_edge(_, _, _info) do
    {:ok, DateTime.utc_now()}
  end

  def outbox_edge(%Character{outbox_id: id}, page_opts, info) do
    opts = %{default_limit: 10}
    Flow.pages(__MODULE__, :fetch_outbox_edge, page_opts, info, id, info, opts)
  end

  def fetch_outbox_edge({page_opts, info}, id) do
    user = info.context.current_user
    {:ok, box} = Activities.page(
      &(&1.id),
      &(&1.id),
      page_opts,
      feed: id,
      table: default_outbox_query_contexts()
    )
    box
  end

  def fetch_outbox_edge(page_opts, info, id) do
    user = info.context.current_user
    Activities.page(
      &(&1.id),
      page_opts,
      feed: id,
      table: default_outbox_query_contexts()
    )
  end

  defp default_outbox_query_contexts() do
    Application.fetch_env!(:moodle_net, Characters)
    |> Keyword.fetch!(:default_outbox_query_contexts)
  end

  ## finally the mutations...

  # def create_character(%{character: attrs, characteristic_id: characteristic_id, context_id: context_id}, info) do
  #   Repo.transact_with(fn ->
  #     with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info),
  #          {:ok, pointer} <- Pointers.one(id: context_id),
  #          :ok <- validate_character_context(pointer),
  #          {:ok, characteristic_pointer} <- Pointers.one(id: characteristic_id) do
  #       characteristic_id = Pointers.follow!(characteristic_pointer)
  #       context = Pointers.follow!(pointer)
  #       attrs = Map.merge(attrs, %{is_public: true})
  #       Characters.create(user, characteristic_pointer, context, attrs)
  #     end
  #   end)
  # end


  # def create_character(%{character: attrs, characteristic_id: characteristic_id}, info) do
  #   Repo.transact_with(fn ->
  #     with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info),
  #          {:ok, characteristic_pointer} <- Pointers.one(id: characteristic_id) do
  #       characteristic_id = Pointers.follow!(characteristic_pointer)
  #       attrs = Map.merge(attrs, %{is_public: true})
  #       Characters.create_with_characteristic(user, characteristic_pointer, attrs)
  #     end
  #   end)
  # end

  def create_character(%{character: attrs, context_id: context_id}, info) do
    Repo.transact_with(fn ->
      with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info),
           {:ok, pointer} <- Pointers.one(id: context_id),
           :ok <- validate_character_context(pointer) do
        context = Pointers.follow!(pointer)
        attrs = Map.merge(attrs, %{is_public: true})
        Characters.create_with_context(user, context, attrs)
      end
    end)
  end

  def create_character(%{character: attrs}, info) do
    Repo.transact_with(fn ->
      with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info) do
        attrs = Map.merge(attrs, %{is_public: true})
        Characters.create(user, attrs)
      end
    end)
  end

  def update_character(%{character: changes, character_id: id}, info) do
    Repo.transact_with(fn ->
      with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info),
           {:ok, character} <- character(%{character_id: id}, info) do
        cond do
          user.local_user.is_instance_admin ->
	    Characters.update(character, changes)

          character.creator_id == user.id ->
	    Characters.update(character, changes)

          true -> GraphQL.not_permitted("update")
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

  defp validate_character_context(pointer) do
    if Pointers.table!(pointer).schema in valid_contexts() do
      :ok
    else
      GraphQL.not_permitted()
    end
  end

  defp valid_contexts do
    Keyword.fetch!(Application.get_env(:moodle_net, Characters), :valid_contexts)
  end
end
