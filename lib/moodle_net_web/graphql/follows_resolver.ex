# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.FollowsResolver do

  alias MoodleNet.{Follows, GraphQL, Repo}
  alias MoodleNet.Follows.{
    Follow,
    FollowCount,
    FollowCountsQueries,
    FollowerCount,
    FollowerCountsQueries,
  }
  alias MoodleNet.GraphQL.{
    Fields, FieldsFlow, Flow, PageFlow, PagesFlow,
    ResolvePages,
  }
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

  def follow_count_edge(%{id: id}, _, info) do
    Flow.fields __MODULE__, :fetch_follow_count_edge, id, info, default: 0
  end

  def fetch_follow_count_edge(_, ids) do
    FieldsFlow.run(
      %FieldsFlow{
        queries: FollowCountsQueries,
        query: FollowCount,
        group_fn: &(&1.creator_id),
        map_fn: &(&1.count),
        filters: [creator_id: ids],
      }
    )
  end

  def follows_edge(%User{id: id}, %{}=page_opts, info) do
    ResolvePages.run(
      %ResolvePages{
        module: __MODULE__,
        fetcher: :fetch_follows_edge,
        context: id,
        page_opts: page_opts,
        info: info,
      }
    )
  end

  def fetch_follows_edge({page_opts, info}, ids) do
    user = GraphQL.current_user(info)
    PagesFlow.run(
      %PagesFlow{
        queries: Follows.Queries,
        query: Follow,
        cursor_fn: &[&1.id],
        group_fn: &(&1.creator_id),
        page_opts: page_opts,
        base_filters: [creator_id: ids, user: user],
        data_filters: [page: [desc: [created: page_opts]]],
        count_filters: [group_count: :context_id],
      }
    )
  end

  def fetch_follows_edge(page_opts, info, ids) do
    user = GraphQL.current_user(info)
    PageFlow.run(
      %PageFlow{
        queries: Follows.Queries,
        query: Follow,
        cursor_fn: &[&1.id],
        page_opts: page_opts,
        base_filters: [creator_id: ids, user: user],
        data_filters: [page: [desc: [created: page_opts]]],
      }
    )
  end

  def follower_count_edge(%{follower_count: c}, _, info) when is_integer(c), do: {:ok, c}

  def follower_count_edge(%{id: id}, _, info) do
    Flow.fields __MODULE__, :fetch_follower_count_edge, id, info, default: 0
  end

  def fetch_follower_count_edge(_, ids) do
    FieldsFlow.run(
      %FieldsFlow{
        queries: FollowerCountsQueries,
        query: FollowerCount,
        group_fn: &(&1.context_id),
        map_fn: &(&1.count),
        filters: [context_id: ids],
      }
    )
  end

  def followers_edge(%{id: id}, %{}=page_opts, info) do
    ResolvePages.run(
      %ResolvePages{
        module: __MODULE__,
        fetcher: :fetch_followers_edge,
        context: id,
        page_opts: page_opts,
        info: info,
      }
    )
  end

  def fetch_followers_edge({page_opts, info}, ids) do
    user = GraphQL.current_user(info)
    PagesFlow.run(
      %PagesFlow{
        queries: Follows.Queries,
        query: Follow,
        cursor_fn: &[&1.id],
        group_fn: &(&1.context_id),
        page_opts: page_opts,
        base_filters: [context_id: ids, user: user],
        data_filters: [page: [desc: [created: page_opts]]],
        count_filters: [group_count: :context_id],
      }
    )
  end

  def fetch_followers_edge(page_opts, info, ids) do
    user = GraphQL.current_user(info)
    PageFlow.run(
      %PageFlow{
        queries: Follows.Queries,
        query: Follow,
        cursor_fn: &[&1.id],
        page_opts: page_opts,
        base_filters: [context_id: ids, user: user],
        data_filters: [page: [desc: [created: page_opts]]],
      }
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
