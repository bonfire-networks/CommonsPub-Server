# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.CommunitiesResolver do
  @moduledoc """
  Performs the GraphQL Community queries.
  """
  alias MoodleNet.{Activities, Collections, Communities, GraphQL, Repo}
  alias MoodleNet.Common.Enums
  alias MoodleNet.GraphQL.{Flow, Page}
  alias MoodleNet.Communities.Community

  def community(%{community_id: id}, %{context: %{current_user: user}}) do
    Communities.one([:default, id: id, user: user])
  end

  def communities(%{}=page_opts, info) do
    Flow.root_page(__MODULE__, :fetch_communities, page_opts, info, %{default_limit: 10})
  end

  def fetch_communities(page_opts, user) do
    Communities.page(
      &(&1.id),
      page_opts,
      [:default, user: user],
      [join: :follower_count, order: :list]
    )
  end

  def collection_count_edge(%Community{id: id}, _, info) do
    Flow.fields __MODULE__, :fetch_collection_count_edge, id, info,
      getter: &Flow.get_tuple_item(&1, id, 1, 0)
  end

  def fetch_collection_count_edge(_, ids) do
    {:ok, counts} = Collections.many(community_id: ids, group_count: :community_id)
    Enums.group(counts, fn {id, _} -> id end)
  end

  def collections_edge(%Community{collections: cs}, _, _info) when is_list(cs), do: {:ok, cs}
  def collections_edge(%Community{id: id}, %{}=page_opts, info) do
    opts = %{default_limit: 10}
    Flow.pages(__MODULE__, :fetch_collections_edge, page_opts, id, info, opts)
  end

  def fetch_collections_edge({page_opts, user}, ids) do
    {:ok, pages} = Collections.pages(
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
    pages
  end

  def fetch_collections_edge(page_opts, user, ids) do
    Collections.page(
      &(&1.id),
      page_opts,
      [community_id: ids, user: user],
      [join: {:actor, :inner},
       join: :follower_count,
       order: :followers_desc,
       preload: :follower_count]
    )
  end

  def inbox_edge(_community, _, _info) do
    {:ok, Page.new([], [], &(&1.id), %{})}
  end

  def outbox_edge(%Community{outbox_id: id}, page_opts, info) do
    Flow.pages(__MODULE__, :fetch_outbox_edge, page_opts, id, info, %{default_limit: 10})
  end

  ### def fetch_outbox_edge({page_opts, user}, id) do

  def fetch_outbox_edge(page_opts, _user, id) do
    Activities.page(
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


  ### mutations


  def create_community(%{community: attrs}, info) do
    with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info) do
      Communities.create(user, attrs)
    end
  end

  def update_community(%{community: changes, community_id: id}, info) do
    Repo.transact_with(fn ->
      with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info),
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


end
