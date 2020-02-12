# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.CommunitiesResolver do
  @moduledoc """
  Performs the GraphQL Community queries.
  """
  alias MoodleNet.{Activities, Batching, Collections, Communities, GraphQL, Instance, Repo}
  alias MoodleNet.Batching.{Edges, EdgesPage, EdgesPages}
  alias MoodleNet.Communities.Community
  import Absinthe.Resolution.Helpers, only: [batch: 3]

  def community(%{community_id: id}, %{context: %{current_user: user}}) do
    Communities.one([:default, id: id, user: user])
  end

  def communities(%{}=page_opts, %{context: %{current_user: user}}) do
    with {:ok, page_opts} <- Batching.full_page_opts(page_opts) do
      Communities.edges_page(
        &(&1.id),
        page_opts,
        [:default, user: user],
        [join: :follower_count, order: :list]
      )
    end
  end

  # def canonical_url_edge(%Community{id: id, actor: %{canonical_url: nil}}, _, _) do
  #   {:ok, Instance.base_url() <> "/communities/" <> id} # canonical URL should be set by AP, but we use FE URL as fallback
  # end
  def canonical_url_edge(%Community{actor: %{canonical_url: url}}, _, _) do
    {:ok, url}
  end

  def create_community(%{community: attrs}, info) do
    with {:ok, user} <- GraphQL.current_user(info) do
      Communities.create(user, attrs)
    end
  end

  def update_community(%{community: changes, community_id: id}, info) do
    Repo.transact_with(fn ->
      with {:ok, user} <- GraphQL.current_user(info),
           {:ok, community} <- community(%{community_id: id}, info) do
        cond do
          user.local_user.is_instance_admin ->
            Communities.update(community, changes)

          community.creator_id == user.id ->
            Communities.update(community, changes)

          is_nil(community.published_at) -> GraphQL.not_found()

          true -> GraphQL.not_permitted()
        end
      end
    end)
  end

  # def delete(%{community_id: id}, info) do
  #   Repo.transact_with(fn ->
  #     with {:ok, user} <- GraphQL.current_user(info),
  #          {:ok, actor} <- Users.fetch_actor(user),
  #          {:ok, community} <- Communities.fetch(id) do
  #       if community.creator_id == actor.id do
  # 	  with {:ok, _} <- Communities.soft_delete(community), do: {:ok, true}
  #       else
  #         GraphQL.not_permitted()
  #       end
  #     end
  #   end)
  #   |> GraphQL.response(info)
  # end

  def collection_count_edge(%Community{id: id}, _, _info) do
    batch {__MODULE__, :batch_collection_count_edge}, id,
      fn edges ->
        case Map.get(edges, id) do
          [{_, count}] -> {:ok, count}
          _ -> {:ok, 0}
        end
      end
  end

  def batch_collection_count_edge(_, ids) do
    {:ok, edges} = Collections.many(
      community_id: ids,
      group_count: :community_id
    )
    Enum.group_by(edges, fn {id, _} -> id end)
  end

  def collections_edge(%Community{collections: cs}, _, info) when is_list(cs), do: {:ok, cs}
  def collections_edge(%Community{id: id}=community, %{}=page_opts, %{context: %{current_user: user}}=info) do
    if GraphQL.in_list?(info) do
      with {:ok, page_opts} <- Batching.limit_page_opts(page_opts) do
        batch {__MODULE__, :batch_collections_edge, {page_opts, user}}, id, EdgesPages.getter(id)
      end
    else
      with {:ok, page_opts} <- Batching.full_page_opts(page_opts) do
        single_collections_edge(page_opts, user, id)
      end
    end
  end

  def single_collections_edge(page_opts, user, ids) do
    Collections.edges_page(
      &(&1.id),
      page_opts,
      [community_id: ids, user: user],
      [join: {:actor, :inner},
       join: :follower_count,
       order: :followers_desc,
       preload: :follower_count]
    )
  end

  def batch_collections_edge({page_opts, user}, ids) do
    {:ok, edges} = Collections.edges_pages(
      &(&1.community_id),
      &(&1.id),
      page_opts,
      [community_id: ids, user: user],
      [join: {:actor, :inner},
       join: :follower_count,
       order: :followers_desc,
       preload: :follower_count],
      [group_count: :community_id]
    )
    edges
  end

  def inbox_edge(_community, _, _info) do
    {:ok, EdgesPage.new([], [], &(&1.id))}
  end

  def outbox_edge(%Community{outbox_id: id}, page_opts, %{context: %{current_user: user}}=info) do
    # if GraphQL.in_list?(info) do
    #   with {:ok, page_opts} <- Batching.limit_page_opts(page_opts) do
    #     batch {__MODULE__, :batch_outbox_edge, {page_opts, user}}, id, EdgesPages.getter(id)
    #   end
    # else
      with {:ok, page_opts} <- Batching.full_page_opts(page_opts) do
        single_outbox_edge(page_opts, user, id)
      end
    # end
  end

  def single_outbox_edge(page_opts, user, id) do
    Activities.edges_page(
      &(&1.id),
      page_opts,
      [join: :feed_activity,
       feed_id: id,
       table: default_outbox_query_contexts(),
       distinct: [desc: :id], # this does the actual ordering *sigh*
       order: :timeline_desc] # this is here because ecto has made questionable choices
    )
  end

  defp default_outbox_query_contexts() do
    Application.fetch_env!(:moodle_net, Communities)
    |> Keyword.fetch!(:default_outbox_query_contexts)
  end

  # def batch_outbox_edge({page_opts, user}, ids) do
  # end

  def last_activity_edge(_, _, _info), do: {:ok, DateTime.utc_now()}

end
