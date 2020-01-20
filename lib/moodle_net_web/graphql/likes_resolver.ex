# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.LikesResolver do
  alias MoodleNet.{
    Accounts,
    Actors,
    Collections,
    Common,
    Communities,
    Fake,
    Flags,
    Follows,
    GraphQL,
    Likes,
    Localisation,
    Repo,
    Users,
  }
  alias Ecto.Association.NotLoaded
  alias MoodleNet.{GraphQL, Likes}
  alias MoodleNet.Actors.Actor
  alias MoodleNet.Batching.{Edges, EdgesPages}
  alias MoodleNet.Collections.Collection
  alias MoodleNet.Common.{NotFoundError, NotPermittedError}
  alias MoodleNet.Communities.Community
  alias MoodleNet.Likes.{AlreadyLikedError, Like, NotLikeableError}
  alias MoodleNet.Meta.{Pointers, Table}
  alias MoodleNet.Resources.Resource
  alias MoodleNet.Threads.{Comment, Thread}
  alias MoodleNet.Users.User
  import Absinthe.Resolution.Helpers, only: [batch: 3]

  def like(%{like_id: id}, %{context: %{current_user: user}}), do: Likes.one(user: user, id: id)

  def like_edge(parent,_, info), do: {:ok, Map.get(parent, :like)}

  def my_like_edge(%{id: id}, _, info) do
    with {:ok, %User{}=user} <- GraphQL.current_user_or(info, nil) do
      batch {__MODULE__, :batch_my_like_edge, user}, id, Edges.getter(id)
    end
  end

  def batch_my_like_edge(current_user, []), do: %{}
  def batch_my_like_edge(user, ids) do
    {:ok, likes} = Likes.edges(&(&1.context_id), creator_id: user.id, context_id: ids)
    likes
  end

  def likes_edge(%{id: id}, _, %{context: %{current_user: user}}) do
    batch {__MODULE__, :batch_likes_edge, user}, id, EdgesPages.getter(id)
  end

  def batch_likes_edge(user, ids) do
    {:ok, edges} = Likes.edges_pages(
      &(&1.context_id),
      &(&1.id),
      [user: user, context_id: ids],
      [order: :timeline_desc],
      [group_count: :context_id]
    )
    edges
  end

  def create_like(%{context_id: id}, info) do
    Repo.transact_with fn ->
      with {:ok, me} <- GraphQL.current_user(info),
           {:ok, pointer} <- Pointers.one(id: id) do
        Likes.create(me, pointer, %{is_local: true})
      end
    end
  end

end
