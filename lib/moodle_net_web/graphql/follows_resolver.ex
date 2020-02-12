# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.FollowsResolver do

  alias MoodleNet.{Batching, Follows, GraphQL, Repo}
  alias MoodleNet.Batching.{Edges, EdgesPages}
  alias MoodleNet.Follows.FollowerCounts
  alias MoodleNet.Meta.Pointers
  alias MoodleNet.Users.User
  import Absinthe.Resolution.Helpers, only: [batch: 3]

  def follow(%{follow_id: id}, %{context: %{current_user: user}}) do
    Follows.one(id: id, user: user)
  end

  def follow(parent, _, _info), do: {:ok, parent.follow}

  def my_follow_edge(%{id: id}, _, info) do
    with {:ok, %User{}=user} <- GraphQL.current_user_or(info, nil) do
      batch {__MODULE__, :batch_my_follow_edge, user}, id, Edges.getter(id)
    end
  end

  def batch_my_follow_edge(%{id: id}, ids) do
    {:ok, edges} = Follows.edges(&(&1.context_id), [:deleted, creator_id: id, context_id: ids])
    edges
  end

  def follower_count_edge(%{id: id}, _, _) do
    batch {__MODULE__, :batch_follower_count_edge}, id,
      fn edges ->
        case Edges.get(edges, id) do
          {:ok, nil} -> {:ok, 0}
          {:ok, other} -> {:ok, other.count}
        end
      end
  end

  def batch_follower_count_edge(_, ids) do
    {:ok, edges} = FollowerCounts.edges(&(&1.context_id), context_id: ids)
    edges
  end

  def followers_edge(%{id: id}, %{}=page_opts, %{context: %{current_user: user}}=info) do
    if GraphQL.in_list?(info) do
      with {:ok, page_opts} <- Batching.limit_page_opts(page_opts) do
        batch {__MODULE__, :batch_followers_edge, {page_opts,user}}, id, EdgesPages.getter(id)
      end
    else
      with {:ok, page_opts} <- Batching.full_page_opts(page_opts) do
        single_followers_edge(page_opts, user, id)
      end
    end
  end

  def single_followers_edge(page_opts, user, ids) do
    Follows.edges_page(
      &(&1.id),
      page_opts,
      [context_id: ids, user: user],
      [order: :timeline_desc]
    )
  end

  def batch_followers_edge({page_opts, user}, ids) do
    {:ok, edges} = Follows.edges_pages(
      &(&1.context_id),
      &(&1.id),
      page_opts,
      [context_id: ids, user: user],
      [order: :timeline_desc],
      [group_count: :context_id]
    )
    edges
  end

  def create_follow(%{context_id: id}, info) do
    Repo.transact_with fn ->
      with {:ok, me} <- GraphQL.current_user(info),
           {:ok, pointer} <- Pointers.one(id: id) do
        Follows.create(me, pointer, %{is_local: true})
      end
    end
  end

  def follow_remote_actor(%{url: url}, info) do
      with {:ok, me} <- GraphQL.current_user(info),
           {:ok, actor} <- MoodleNet.ActivityPub.Adapter.get_actor_by_ap_id(url) do
          Follows.create(me, actor, %{is_local: true})
    end
  end
end
