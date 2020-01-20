# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.FollowsResolver do

  alias MoodleNet.{Batching, Follows, GraphQL, Repo}
  alias MoodleNet.Batching.{Edges, EdgesPages}
  alias MoodleNet.Collections.Collection
  alias MoodleNet.Communities.Community
  alias MoodleNet.Follows.{Follow, NotFollowableError}
  alias MoodleNet.Meta.{Pointers, Table}
  alias MoodleNet.Resources.Resource
  alias MoodleNet.Threads.Comment
  alias MoodleNet.Users.User
  alias MoodleNetWeb.GraphQL.{CommonResolver, FollowsResolver}
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
    {:ok, edges} = Follows.edges(&(&1.context_id), creator_id: id, context_id: ids)
    edges
  end

  def follower_count_edge(%{id: id}, _, _) do
    batch {__MODULE__, :batch_follower_count_edge}, id, Edges.getter(id)
  end

  def batch_follower_count_edge(_, ids) do
    {:ok, edges} = FollowerCounts.edges(
      &(&1.context_id),
      [context_id: ids]
    )
    edges
  end

  def followers_edge(%{id: id}, _, %{context: %{current_user: user}}) do
    batch {__MODULE__, :batch_followers_edge, user}, id, EdgesPages.getter(id)
  end

  def batch_followers_edge(user, ids) do
    {:ok, edges} = Follows.edges_pages(
      &(&1.context_id),
      &(&1.id),
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

end
