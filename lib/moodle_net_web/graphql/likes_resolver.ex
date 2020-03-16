# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.LikesResolver do
  alias MoodleNet.{GraphQL, Likes, Repo}
  alias MoodleNet.GraphQL.{Fields, Flow}
  alias MoodleNet.Likes.LikerCounts
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

  def fetch_my_like_edge(_user, []), do: %{}
  def fetch_my_like_edge(user, ids) do
    {:ok, likes} = Likes.fields(&(&1.context_id), [:deleted, creator_id: user.id, context_id: ids])
    likes
  end

  def likers_edge(%{id: id}, %{}=page_opts, info) do
    opts = %{default_limit: 10}
    Flow.pages(__MODULE__, :fetch_likers_edge, page_opts, id, info, opts)
  end

  def fetch_likers_edge({page_opts, user}, ids) do
    {:ok, pages} = Likes.pages(
      &(&1.context_id),
      &(&1.id),
      page_opts,
      [user: user, context_id: ids],
      [order: :timeline_desc],
      [group_count: :context_id]
    )
    pages
  end

  def fetch_likers_edge(page_opts, user, ids) do
    Likes.page(
      &(&1.id),
      page_opts,
      [user: user, context_id: ids],
      [order: :timeline_desc]
    )
  end

  def liker_count_edge(%{id: id}, _, info) do
    Flow.fields __MODULE__, :fetch_liker_count_edge, id, info,
      default: 0,
      getter: fn fields ->
        case Fields.get(fields, id) do
          {:ok, nil} -> {:ok, 0}
          {:ok, other} -> {:ok, other.count}
        end
      end
  end

  def fetch_liker_count_edge(_, ids) do
    {:ok, fields} = LikerCounts.fields(&(&1.context_id), context_id: ids)
    fields
  end


  def likes_edge(%{id: id}, %{}=page_opts, info) do
    opts = %{default_limit: 10}
    Flow.pages(__MODULE__, :fetch_likes_edge, page_opts, id, info, opts)
  end

  def fetch_likes_edge({page_opts, user}, ids) do
    {:ok, pages} = Likes.pages(
      &(&1.context_id),
      &(&1.id),
      page_opts,
      [:deleted, user: user, context_id: ids],
      [order: :timeline_desc],
      [group_count: :context_id]
    )
    pages
  end

  def fetch_likes_edge(page_opts, user, ids) do
    Likes.page(
      &(&1.id),
      page_opts,
      [user: user, context_id: ids],
      [order: :timeline_desc]
    )
  end

  def like_count_edge(%{id: id}, _, info) do
    Flow.fields __MODULE__, :fetch_like_count_edge, id, info,
      default: 0,
      getter: fn fields ->
        case Fields.get(fields, id) do
          {:ok, nil} -> {:ok, 0}
          {:ok, other} -> {:ok, other.count}
        end
      end
  end

  def fetch_like_count_edge(_, ids) do
    {:ok, fields} = LikerCounts.fields(&(&1.context_id), context_id: ids)
    fields
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
