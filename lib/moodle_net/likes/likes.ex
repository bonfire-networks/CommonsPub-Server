# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Likes do
  alias MoodleNet.{Activities, Common, Repo}
  alias MoodleNet.Common.Contexts
  alias MoodleNet.FeedPublisher
  alias MoodleNet.Feeds.FeedActivities
  alias MoodleNet.GraphQL.Fields
  alias MoodleNet.Likes.{AlreadyLikedError, Like, NotLikeableError, Queries}
  alias MoodleNet.Meta.{Pointer, Pointers}
  alias MoodleNet.Users.User

  def one(filters \\ []), do: Repo.single(Queries.query(Like, filters))

  def many(filters \\ []), do: {:ok, Repo.all(Queries.query(Like, filters))}

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

  defp ap_publish(user, %Like{is_local: true} = like) do
    MoodleNet.FeedPublisher.publish(%{"context_id" => like.context_id, "user_id" => user.id})
  end
  defp ap_publish(_), do: :ok

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
        case one([:deleted, context_id: liked.id, creator_id: liker.id]) do
          {:ok, _} ->
            {:error, AlreadyLikedError.new("user")}

          _ ->
            with {:ok, like} <- insert(liker, liked, fields),
                 :ok <- publish(liker, liked, like, "created"),
                 :ok <- ap_publish(liker, like) do
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

  @spec soft_delete(Like.t()) :: {:ok, Like.t()} | {:error, any}
  def soft_delete(%Like{} = like) do
    Repo.transact_with(fn ->
      with {:ok, like} <- Common.soft_delete(like),
            :ok <- ap_publish(like) do
        {:ok, like}
      end
    end)
  end

  defp valid_contexts() do
    Application.fetch_env!(:moodle_net, __MODULE__)
    |> Keyword.fetch!(:valid_contexts)
  end

end
