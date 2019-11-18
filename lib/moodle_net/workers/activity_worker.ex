defmodule MoodleNet.Workers.ActivityWorker do
  use Oban.Worker, queue: "activities_outbox", max_attempts: 1

  require Logger

  alias MoodleNet.{Common, Meta, Repo, Users, Comments}
  alias MoodleNet.Activities
  alias MoodleNet.Communities
  alias MoodleNet.Communities.Community
  alias MoodleNet.Collections
  alias MoodleNet.Collections.Collection
  alias MoodleNet.Users.User
  alias MoodleNet.Common.{Follow, Like}
  alias MoodleNet.Comments.{Comment, Thread}

  @impl Worker
  def perform(
        %{
          "verb" => verb,
          "user_id" => user_id,
          "context_id" => context_id,
        },
        _job
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
    %Follow{followed: followed} = Common.preload_follow(follow)
    Meta.follow!(followed)
  end

  defp fetch_target!(%Like{} = like) do
    %Like{liked: liked} = Common.preload_like(like)
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
    Repo.insert(Users.Outbox.changeset(user, activity))
  end

  defp insert_outbox!(%Community{} = community, activity) do
    {:ok, _} = Repo.insert(Communities.Outbox.changeset(community, activity))
  end

  defp insert_outbox!(%Collection{} = collection, activity) do
    {:ok, _} = Repo.insert(Collections.Outbox.changeset(collection, activity))

    {:ok, comm} = Communities.fetch(collection.community_id)
    insert_outbox!(comm, activity)
  end

  defp insert_outbox!(%{__struct__: type}, _activity) do
    Logger.warn("Unsupported type for outbox: #{to_string(type)}")
  end

  defp insert_inbox!(%User{} = user, activity) do
    user
    |> Users.Inbox.changeset(activity)
    |> Repo.insert!()

    insert_follower_inbox!(user, activity)
  end

  defp insert_inbox!(%Community{} = community, activity) do
    community
    |> Communities.Inbox.changeset(activity)
    |> Repo.insert!()

    insert_follower_inbox!(community, activity)
  end

  defp insert_inbox!(%Collection{} = collection, activity) do
    collection
    |> Collections.Inbox.changeset(activity)
    |> Repo.insert!()
    insert_follower_inbox!(collection, activity)

    {:ok, community} = Communities.fetch(collection.community_id)
    insert_inbox!(community, activity)
  end

  defp insert_inbox!(%Thread{} = thread, activity) do
    insert_follower_inbox!(thread, activity)

    {:ok, context} = Comments.fetch_thread_context(thread)
    insert_inbox!(context, activity)
  end

  defp insert_inbox!(%Comment{} = comment, activity) do
    insert_follower_inbox!(comment, activity)
  end

  defp insert_follower_inbox!(target, activity) do
    for follow <- Common.list_by_followed(target) do
      %Follow{follower: follower} = Common.preload_follow(follow)

      follower
      |> Users.Inbox.changeset(activity)
      |> Repo.insert!()
    end
  end
end
