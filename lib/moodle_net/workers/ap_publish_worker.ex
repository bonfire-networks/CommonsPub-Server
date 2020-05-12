# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Workers.APPublishWorker do
  use ActivityPub.Workers.WorkerHelper, queue: "mn_ap_publish", max_attempts: 1

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
  def perform(%{"context_id" => context_id, "op" => verb}, _job) do
      Pointers.one!(id: context_id)
      |> Pointers.follow!()
      |> only_local(&publish/2, verb)
  end

  defp publish(%Collection{} = collection, "create"), do: Publisher.create_collection(collection)

  defp publish(%Comment{} = comment, "create") do
    Publisher.comment(comment)
  end

  defp publish(%Resource{} = resource, "create") do
    Publisher.create_resource(resource)
  end

  defp publish(%Community{} = community, "create") do
    Publisher.create_community(community)
  end

  defp publish(%Follow{} = follow, "create") do
    Publisher.follow(follow)
  end

  defp publish(%Follow{} = follow, "delete") do
    Publisher.unfollow(follow)
  end

  defp publish(%Flag{} = flag, "create") do
    Publisher.flag(flag)
  end

  defp publish(%Block{} = block, "create") do
    Publisher.block(block)
  end

  defp publish(%Block{} = block, "delete") do
    Publisher.unblock(block)
  end

  defp publish(%Like{} = like, "create") do
    Publisher.like(like)
  end

  defp publish(%Like{} = like, "delete") do
    Publisher.unlike(like)
  end

  defp publish(context, verb) do
    Logger.warn("Unsupported action for AP publisher: #{context.id}, #{verb} #{context.__struct__}")

    :ignored
  end

  defp only_local(%Resource{collection_id: collection_id} = context, commit_fn, verb) do
    with {:ok, collection} <- MoodleNet.Collections.one(id: collection_id),
         {:ok, actor} <- MoodleNet.Actors.one(id: collection.actor_id),
         true <- is_nil(actor.peer_id) do
      commit_fn.(context, verb)
    else _ ->
      :ignored
    end
  end

  defp only_local(%{is_local: true} = context, commit_fn, verb) do
    commit_fn.(context, verb)
  end

  defp only_local(%{actor: %{peer_id: nil}} = context, commit_fn, verb) do
    commit_fn.(context, verb)
  end

  defp only_local(_, _, _), do: :ignored
end
