# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Workers.APPublishWorker do
  use Oban.Worker, queue: "mn_ap_publish", max_attempts: 2

  require Logger

  alias MoodleNet.{Actors, Meta, Users}
  alias MoodleNet.ActivityPub.Publisher
  alias MoodleNet.Comments.Comment
  alias MoodleNet.Common.{Block, Flag, Follow, Like}
  alias MoodleNet.Collections.Collection
  alias MoodleNet.Communities.Community
  alias MoodleNet.Resources.Resource

  @impl Worker
  def perform(%{"context_id" => context_id}, _job) do
    context = context_id |> Meta.find!() |> Meta.follow!()

    only_local(context, &publish/1)

    # ignore failure for now
    :ok
  end

  defp publish(%Collection{} = collection), do: ignore_deleted(collection, &Publisher.create_collection/1)

  defp publish(%Comment{} = comment) do
    ignore_deleted(comment, &Publisher.comment/1)
  end

  defp publish(%Resource{} = resource) do
    ignore_deleted(resource, &Publisher.create_resource/1)
  end

  defp publish(%Community{} = community) do
    IO.inspect(community)
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
      IO.inspect(context)
      commit_fn.(context)
    end
  end

  defp only_local(%{actor_id: actor_id} = context, commit_fn) do
    with {:ok, actor} <- Actors.fetch(actor_id) do
      if is_nil(actor.peer_id) do
        commit_fn.(context)
      else
        :ignored
      end
    end
  end

  defp only_local(%{creator_id: creator_id} = context, commit_fn) do
    with {:ok, user} <- Users.fetch_private(creator_id),
         {:ok, actor} <- Actors.fetch(user.actor_id) do
      if is_nil(actor.peer_id) do
        commit_fn.(context)
      else
        :ignored
      end
    end
  end

  defp only_local(context, commit_fn) do
    commit_fn.(context)
  end
end
