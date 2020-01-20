# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Likes do

  alias MoodleNet.Repo
  alias MoodleNet.Batching.{Edges, EdgesPages, NodesPage}
  alias MoodleNet.Likes.{AlreadyLikedError, Like, NotLikeableError, Queries}
  alias MoodleNet.Meta.{Pointers, Table}
  alias MoodleNet.Users.{LocalUser, User}
  import Ecto.Query
  alias Ecto.Changeset

  def one(filters \\ []), do: Repo.single(Queries.query(Like, filters))

  def many(filters \\ []), do: {:ok, Repo.all(Queries.query(Like, filters))}

  def nodes_page(cursor_fn, base_filters \\ [], data_filters \\ [], count_filters \\ [])
  when is_function(cursor_fn, 1) do
    {data_q, count_q} = Queries.queries(Like, base_filters, data_filters, count_filters)
    with {:ok, [data, count]} <- Repo.transact_many(all: data_q, count: count_q) do
      {:ok, NodesPage.new(data, count, cursor_fn)}
    end
  end

  def edges(group_fn, filters \\ [])
  when is_function(group_fn, 1) do
    {:ok, edges} = many(filters)
    {:ok, Edges.new(edges, group_fn)}
  end

  def edges_pages(group_fn, cursor_fn, base_filters \\ [], data_filters \\ [], count_filters \\ [])
  when is_function(group_fn, 1) and is_function(cursor_fn, 1) do
    {data_q, count_q} = Queries.queries(Like, base_filters, data_filters, count_filters)
    with {:ok, [data, count]} <- Repo.transact_many(all: data_q, all: count_q) do
      {:ok, EdgesPages.new(data, count, group_fn, cursor_fn)}
    end
  end

  def insert(%User{} = liker, liked, fields) do
    Repo.insert(Like.create_changeset(liker, liked, fields))
  end

  defp publish(%Like{} = _like, _verb) do
    # MoodleNet.FeedPublisher.publish(%{
    #   "verb" => verb,
    #   "creator_id" => like.creator_id,
    #   "context_id" => like.id
    # })
    :ok
  end

  @doc """
  NOTE: assumes liked participates in meta, otherwise gives constraint error changeset
  """
  def create(%User{} = liker, liked, fields) do
    liked = Pointers.maybe_forge!(liked)
    %Table{schema: table} = Pointers.table!(liked)
    if table in valid_contexts() do
      Repo.transact_with(fn ->
        case one(context_id: liked.id, creator_id: liker.id) do
          {:ok, _} ->
            {:error, AlreadyLikedError.new("user")}
  
          _ ->
            with {:ok, like} <- insert(liker, liked, fields),
                 :ok <- publish(like, "create") do
              {:ok, like}
            end
        end
      end)
    else
      {:error, NotLikeableError.new(table)}
    end
  end

  def update(%Like{} = like, fields) do
    Repo.update(Like.update_changeset(like, fields))
  end

  defp valid_contexts() do
    Application.fetch_env!(:moodle_net, __MODULE__)
    |> Keyword.fetch!(:valid_contexts)
  end

end
