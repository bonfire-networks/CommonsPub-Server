# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Likes do

  alias MoodleNet.{Activities, Common, Repo}
  alias MoodleNet.Batching.{Edges, EdgesPages, NodesPage}
  alias MoodleNet.Feeds.FeedActivities
  alias MoodleNet.Likes.{AlreadyLikedError, Like, NotLikeableError, Queries}
  alias MoodleNet.Meta.{Pointer, Pointers}
  alias MoodleNet.Users.User

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

  defp publish(creator, %{outbox_id: context_outbox_id}, %Like{} = like, verb) do
    attrs = %{verb: verb, is_local: like.is_local}
    with {:ok, activity} <- Activities.create(creator, like, attrs) do
      FeedActivities.publish(activity, [creator.outbox_id, context_outbox_id])
    end
  end
  defp publish(creator, _context, %Like{} = like, verb) do
    attrs = %{verb: verb, is_local: like.is_local}
    with {:ok, activity} <- Activities.create(creator, like, attrs) do
      FeedActivities.publish(activity, [creator.outbox_id])
    end
  end

  defp federate(%Like{is_local: true} = like) do
    MoodleNet.FeedPublisher.publish(%{
      "context_id" => like.context_id,
      "user_id" => like.creator_id,
    })
    :ok
  end
  defp federate(_), do: :ok

  @doc """
  NOTE: assumes liked participates in meta, otherwise gives constraint error changeset
  """
  def create(liker, liked, fields)
  def create(%User{} = liker, %Pointer{} = liked, fields) do
    create(liker, Pointers.follow!(liked), fields)
  end

  def create(%User{} = liker, %{__struct__: ctx} = liked, fields) do
    if ctx in valid_contexts() do
      Repo.transact_with(fn ->
        case one(context_id: liked.id, creator_id: liker.id) do
          {:ok, _} ->
            {:error, AlreadyLikedError.new("user")}
  
          _ ->
            with {:ok, like} <- insert(liker, liked, fields),
                 :ok <- publish(liker, liked, like, "create") do
              {:ok, like}
            end
        end
      end)
    else
      {:error, NotLikeableError.new(ctx)}
    end
  end

  def update(%Like{} = like, fields) do
    Repo.update(Like.update_changeset(like, fields))
  end

  @spec undo(Like.t()) :: {:ok, Like.t()} | {:error, any}
  def undo(%Like{} = like) do
    Repo.transact_with(fn ->
      with {:ok, like} <- Common.soft_delete(like),
            :ok <- federate(like) do
        {:ok, like}
      end
    end)
  end

  defp valid_contexts() do
    Application.fetch_env!(:moodle_net, __MODULE__)
    |> Keyword.fetch!(:valid_contexts)
  end
end
