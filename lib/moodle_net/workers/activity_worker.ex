# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Workers.ActivityWorker do
  use Oban.Worker, queue: "mn_activities", max_attempts: 1

  require Logger

  alias MoodleNet.{Activities, Communities, Collections, Common, Meta, Repo, Users, Comments}
  alias MoodleNet.Common.{Follow, Like}
  alias MoodleNet.Comments.{Comment, Thread}
  alias MoodleNet.Communities.Community
  alias MoodleNet.Collections.Collection
  alias MoodleNet.Users.User
  import Ecto.Query
  import MoodleNet.Workers.Utils, only: [run_with_debug: 3]

  @impl Worker
  def perform(arg, job), do: run_with_debug(__MODULE__, &run_job/1, job, arg)

  defp run_job(
    %{"verb" => verb,
      "creator_id" => user_id,
      "context_id" => context_id,
    },
  ) do
    Repo.transaction(fn ->
      {:ok, user} = Users.fetch(user_id)
      context = context_id |> Meta.find!() |> Meta.follow!()
      target = fetch_target!(context)

      {:ok, activity} = Activities.create(context, user, %{"verb" => verb, "is_local" => true})
      # active user is always notified
      insert_outbox!(user, activity)
      insert_outbox!(target, activity)

      # active user always has followers notified
      # 'I think, therefore I am'
      insert_inbox!(user, activity)
      insert_inbox!(target, activity)
    end)
  end

  defp fetch_target!(%Follow{} = follow) do
    %Follow{context: followed} = Repo.preload(follow, [:context, :creator])
    Meta.follow!(followed)
  end

  defp fetch_target!(%Like{} = like) do
    %Like{context: liked} = Repo.preload(like, [:context, :creator])
    Meta.follow!(liked)
  end

  defp fetch_target!(%Comment{} = comment) do
    {:ok, thread} = Comments.fetch_comment_thread(comment)
    # TODO: include reply_to comment
    thread
  end

  defp fetch_target!(%Thread{} = thread) do
    {:ok, context} = Comments.fetch_thread_context(thread)
    context
  end

  defp insert_outbox!(%User{} = user, activity) do
    Repo.insert!(Users.Outbox.changeset(user, activity))
  end

  defp insert_outbox!(%Community{} = community, activity) do
    Repo.insert!(Communities.Outbox.changeset(community, activity))
  end

  defp insert_outbox!(%Collection{} = collection, activity) do
    Repo.insert!(Collections.Outbox.changeset(collection, activity))

    {:ok, comm} = Communities.fetch(collection.community_id)
    insert_outbox!(comm, activity)
  end

  defp insert_outbox!(%{__struct__: type}, _activity) do
    Logger.warn("Unsupported type for outbox: #{to_string(type)}")
  end

  defp insert_inbox!(%Collection{} = collection, activity) do
    insert_follower_inbox!(collection, activity)

    {:ok, community} = Communities.fetch(collection.community_id)
    insert_inbox!(community, activity)
  end

  defp insert_inbox!(%Thread{} = thread, activity) do
    insert_follower_inbox!(thread, activity)

    {:ok, context} = Comments.fetch_thread_context(thread)
    insert_inbox!(context, activity)
  end

  defp insert_inbox!(other, activity) do
    insert_follower_inbox!(other, activity)
  end

  defp insert_follower_inbox!(target, %{id: activity_id} = activity) do
    for follow <- Common.list_by_followed(target) do
      follower_id = follow.creator_id
      %Follow{creator: follower} = Repo.preload(follow, [:creator, :context])

      # FIXME: handle duplicates
      follower
      |> Users.Inbox.changeset(activity)
      |> Repo.insert!()
    end
  end

end
