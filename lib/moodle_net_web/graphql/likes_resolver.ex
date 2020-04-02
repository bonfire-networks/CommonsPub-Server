# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.LikesResolver do
  alias MoodleNet.{GraphQL, Likes, Repo}
  alias MoodleNet.GraphQL.{Fields, FieldsFlow, Flow, PageFlow, PagesFlow}
  alias MoodleNet.Likes.{Like, LikeCount, LikerCount, LikerCountsQueries}
  alias MoodleNet.Meta.Pointers
  alias MoodleNet.Users.User

  def like(%{like_id: id}, %{context: %{current_user: user}}) do
    Likes.one(user: user, id: id)
  end

  def like_edge(parent,_, _info), do: {:ok, Map.get(parent, :like)}

  def my_like_edge(%{id: id}, _, info) do
    with {:ok, %User{}} <- GraphQL.current_user_or(info, nil) do
      Flow.fields __MODULE__, :fetch_my_like_edge, id, info
    end
  end

  def fetch_my_like_edge(_info, []), do: %{}
  def fetch_my_like_edge(info, ids) do
    user = GraphQL.current_user(info)
    {:ok, likes} = Likes.fields(&(&1.context_id), [:deleted, creator_id: user.id, context_id: ids])
    likes
  end

  def likers_edge(%{id: id}, %{}=page_opts, info) do
    vals = [&Ecto.ULID.cast/1]
    opts = %{default_limit: 10}
    Flow.pages(__MODULE__, :fetch_likers_edge, page_opts, id, info, vals, opts)
  end

  def fetch_likers_edge({page_opts, info}, ids) do
    user = GraphQL.current_user(info)
    PagesFlow.run(
      %PagesFlow{
        queries: Likes.Queries,
        query: Like,
        cursor_fn: &[&1.id],
        group_fn: &(&1.context_id),
        page_opts: page_opts,
        base_filters: [:deleted, user: user, context_id: ids],
        data_filters: [page: [desc: [created: page_opts]]],
        count_filters: [group_count: :context_id],
      }
    )
  end

  def fetch_likers_edge(page_opts, info, ids) do
    user = GraphQL.current_user(info)
    PageFlow.run(
      %PageFlow{
        queries: Likes.Queries,
        query: Like,
        cursor_fn: &[&1.id],
        page_opts: page_opts,
        base_filters: [:deleted, user: user, context_id: ids],
        data_filters: [page: [desc: [created: page_opts]]],
      }
    )
  end


  def liker_count_edge(%{id: id}, _, info) do
    Flow.fields __MODULE__, :fetch_liker_count_edge, id, info, default: 0
  end

  def fetch_liker_count_edge(_, ids) do
    FieldsFlow.run(
      %FieldsFlow{
        queries: LikerCountsQueries,
        query: LikerCount,
        group_fn: &(&1.context_id),
        map_fn: &(&1.count),
        filters: [context_id: ids],
      }
    )
  end

  def likes_edge(%{id: id}, %{}=page_opts, info) do
    vals = [&Ecto.ULID.cast/1]
    opts = %{default_limit: 10}
    Flow.pages(__MODULE__, :fetch_likes_edge, page_opts, id, info, vals, opts)
  end

  def fetch_likes_edge({page_opts, info}, ids) do
    user = GraphQL.current_user(info)
    PagesFlow.run(
      %PagesFlow{
        queries: Likes.Queries,
        query: Like,
        cursor_fn: &[&1.id],
        group_fn: &(&1.context_id),
        page_opts: page_opts,
        base_filters: [:deleted, user: user, creator_id: ids],
        data_filters: [page: [desc: [created: page_opts]]],
        count_filters: [group_count: :creator_id],
      }
    )
  end

  def fetch_likes_edge(page_opts, info, ids) do
    user = GraphQL.current_user(info)
    PageFlow.run(
      %PageFlow{
        queries: Likes.Queries,
        query: Like,
        cursor_fn: &[&1.id],
        page_opts: page_opts,
        base_filters: [:deleted, user: user, creator_id: ids],
        data_filters: [page: [desc: [created: page_opts]]],
      }
    )
  end

  def like_count_edge(%{id: id}, _, info) do
    Flow.fields __MODULE__, :fetch_liker_count_edge, id, info, default: 0
  end

  def fetch_like_count_edge(_, ids) do
    FieldsFlow.run(
      %FieldsFlow{
        queries: LikeCountsQueries,
        query: LikeCount,
        group_fn: &(&1.context_id),
        map_fn: &(&1.count),
        filters: [context_id: ids],
      }
    )
  end

  def create_like(%{context_id: id}, info) do
    Repo.transact_with fn ->
      with {:ok, me} <- GraphQL.current_user_or_not_logged_in(info),
           {:ok, pointer} <- Pointers.one(id: id) do
        Likes.create(me, pointer, %{is_local: true})
      end
    end
  end

end
