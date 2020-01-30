# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Workers.APPublishWorker do
  use Oban.Worker, queue: "mn_ap_publish", max_attempts: 1

  require Logger

  alias MoodleNet.ActivityPub.Publisher
  alias MoodleNet.Blocks.Block
  alias MoodleNet.Flags.Flag
  alias MoodleNet.Follows.Follow
  alias MoodleNet.Likes.Like
  alias MoodleNet.Collections.Collection
  alias MoodleNet.Communities.Community
  alias MoodleNet.Meta.Pointers
  alias MoodleNet.Resources.Resource
  alias MoodleNet.Threads.Comment

  @impl Worker
  def perform(%{"context_id" => context_id}, _job) do
      Pointers.one!(id: context_id)
      |> Pointers.follow!()
      |> only_local(&publish/1)
  end

  defp publish(%Collection{} = collection), do: ignore_deleted(collection, &Publisher.create_collection/1)

  defp publish(%Comment{} = comment) do
    ignore_deleted(comment, &Publisher.comment/1)
  end

  defp publish(%Resource{} = resource) do
    ignore_deleted(resource, &Publisher.create_resource/1)
  end

  defp publish(%Community{} = community) do
    ignore_deleted(community, &Publisher.create_community/1)
  end

  defp publish(%Follow{} = follow) do
    publish_deleted(follow, &Publisher.follow/1, &Publisher.unfollow/1)
  end

  defp publish(%Flag{} = flag) do
    ignore_deleted(flag, &Publisher.flag/1)
  end

  defp publish(%Block{} = block) do
    publish_deleted(block, &Publisher.block/1, &Publisher.unblock/1)
  end

  defp publish(%Like{} = like) do
    publish_deleted(like, &Publisher.like/1, &Publisher.unlike/1)
  end

  defp publish(context) do
    Logger.warn("Unsupported type for AP publisher: #{context.id}")

    :ignored
  end

  defp publish_deleted(%{deleted_at: deleted_at} = context, default_fn, _deleted_fn) when is_nil(deleted_at) do
    default_fn.(context)
  end

  defp publish_deleted(context, _default_fn, deleted_fn) do
    deleted_fn.(context)
  end

  defp ignore_deleted(%{deleted_at: deleted_at} = context, commit_fn) do
    if is_nil(deleted_at) do
      commit_fn.(context)
    end
  end

  defp only_local(%Resource{collection_id: collection_id} = context, commit_fn) do
    with {:ok, collection} <- MoodleNet.Collections.one(id: collection_id),
         {:ok, actor} <- MoodleNet.Actors.one(id: collection.actor_id),
         true <- is_nil(actor.peer_id) do
      commit_fn.(context)
    else _ ->
      :ignored
    end
  end

  defp only_local(%{is_local: true} = context, commit_fn) do
    commit_fn.(context)
  end

  defp only_local(%{peer_id: nil} = context, commit_fn) do
    commit_fn.(context)
  end

  defp only_local(_, _), do: :ignored
end
