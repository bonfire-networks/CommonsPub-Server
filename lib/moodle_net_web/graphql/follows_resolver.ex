# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.FollowsResolver do

  alias MoodleNet.{Follows, GraphQL, Repo}
  alias MoodleNet.Follows.FollowerCounts
  alias MoodleNet.GraphQL.{Fields, Flow}
  alias MoodleNet.Meta.Pointers
  alias MoodleNet.Users.User
  import Absinthe.Resolution.Helpers, only: [batch: 3]

  def follow(%{follow_id: id}, info) do
    Follows.one(id: id, user: GraphQL.current_user(info))
  end

  def follow(parent, _, _info), do: {:ok, parent.follow}

  def my_follow_edge(%{id: id}, _, info) do
    with {:ok, %User{}} <- GraphQL.current_user_or(info, nil) do
      Flow.fields(__MODULE__, :fetch_my_follow_edge, id, info)
    end
  end

  def fetch_my_follow_edge(info, ids) do
    case GraphQL.current_user(info) do
      nil -> nil
      user ->
        {:ok, fields} = Follows.fields(
        &(&1.context_id),
        [:deleted, creator_id: user.id, context_id: ids])
        fields
    end
  end

  def follower_count_edge(%{id: id}, _, _) do
    batch {__MODULE__, :batch_follower_count_edge}, id,
      fn edges ->
        IO.inspect(:getter)
        case Fields.get(edges, id) do
          {:ok, nil} -> {:ok, 0}
          {:ok, other} -> {:ok, other.count}
        end
      end
  end

  def batch_follower_count_edge(_info, ids) do
    FollowerCounts.fields(&(&1.context_id), context_id: ids)
  end

  def followers_edge(%{id: id}, %{}=page_opts, info) do
    opts = %{default_limit: 10}
    Flow.pages(__MODULE__, :fetch_followers_edge, page_opts, id, info, opts)
  end

  def fetch_followers_edge({page_opts, info}, ids) do
    user = GraphQL.current_user(info)
    {:ok, edges} = Follows.pages(
      &(&1.context_id),
      &(&1.id),
      page_opts,
      [context_id: ids, user: user],
      [order: :timeline_desc],
      [group_count: :context_id]
    )
    edges
  end

  def fetch_followers_edge(page_opts, info, ids) do
    user = GraphQL.current_user(info)
    Follows.page(
      &(&1.id),
      page_opts,
      [context_id: ids, user: user],
      [order: :timeline_desc]
    )
  end

  def create_follow(%{context_id: id}, info) do
    Repo.transact_with fn ->
      with {:ok, me} <- GraphQL.current_user_or_not_logged_in(info),
           {:ok, pointer} <- Pointers.one(id: id) do
        Follows.create(me, pointer, %{is_local: true})
      end
    end
  end

  def follow_remote_actor(%{url: url}, info) do
    Repo.transact_with fn ->
      with {:ok, me} <- GraphQL.current_user_or_not_logged_in(info),
           {:ok, actor} <- MoodleNet.ActivityPub.Adapter.get_actor_by_ap_id(url) do
        Follows.create(me, actor, %{is_local: true})
      end
    end
  end
end
