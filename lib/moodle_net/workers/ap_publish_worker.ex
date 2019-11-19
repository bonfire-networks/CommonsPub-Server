# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Workers.APPublishWorker do
  use Oban.Worker, queue: "mn_ap_publish", max_attempts: 2

  require Logger

  alias MoodleNet.Meta
  alias MoodleNet.ActivityPub.Publisher
  alias MoodleNet.Comments.Comment
  alias MoodleNet.Common.{Block, Flag, Follow, Like}
  alias MoodleNet.Collections.Collection
  alias MoodleNet.Communities.Community
  alias MoodleNet.Resources.Resource

  @impl Worker
  def perform(%{"context_id" => context_id}, _job) do
    context = context_id |> Meta.find!() |> Meta.follow!()

    # ignore allow failure for now
    _ = publish(context)
  end

  defp publish(%Collection{} = collection), do: ignore_deleted(collection, &Publisher.create_collection/1)

  defp publish(%Comment{is_local: true} = comment) do
    ignore_deleted(comment, &Publisher.comment/1)
  end

  defp publish(%Resource{is_local: true} = resource) do
    ignore_deleted(resource, &Publisher.create_resource/1)
  end

  defp publish(%Community{is_local: true} = community) do
    ignore_deleted(community, &Publisher.create_community/1)
  end

  defp publish(%Follow{is_local: true} = follow) do
    publish_deleted(follow, &Publisher.follow/1, &Publisher.unfollow/1)
  end

  defp publish(%Flag{is_local: true} = flag) do
    ignore_deleted(flag, &Publisher.flag/1)
  end

  defp publish(%Block{is_local: true} = block) do
    publish_deleted(block, &Publisher.block/1, &Publisher.unblock/1)
  end

  defp publish(%Like{is_local: true} = like) do
    publish_deleted(like, &Publisher.like/1, &Publisher.unlike/1)
  end

  defp publish(context) do
    Logger.warn("Unsupported type for AP publisher: #{context.id}")

    {:error, :unsupported}
  end

  defp publish_deleted(%{deleted_at: deleted_at} = context, default_fn, _deleted_fn) when is_nil(deleted_at) do
    default_fn.(context)
  end

  defp publish_deleted(context, _default_fn, deleted_fn) do
    deleted_fn.(context)
  end

  defp ignore_deleted(%{deleted_at: deleted_at}, commit_fn) do
    if not is_nil(deleted_at) do
      commit_fn.(deleted_at)
    end
  end
end
