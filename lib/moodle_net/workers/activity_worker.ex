defmodule MoodleNet.Workers.ActivityWorker do
  use Oban.Worker, queue: "activities_outbox", max_attempts: 1

  alias MoodleNet.Activities
  alias MoodleNet.Communities
  alias MoodleNet.Communities.Community
  alias MoodleNet.Collections
  alias MoodleNet.Collections.Collection
  alias MoodleNet.Users
  alias MoodleNet.Users.User
  alias MoodleNet.{Meta, Repo}

  @impl Worker
  def perform(
        %{
          "verb" => verb,
          "user_id" => user_id,
          "context_id" => context_id,
          "target_id" => target_id
        },
        _job
      ) do
    Repo.transaction(fn ->
      {:ok, user} = Users.fetch(user_id)
      context = context_id |> Meta.find!() |> Meta.follow!()

      {:ok, activity} = Activities.create(context, user, %{"verb" => verb, "is_local" => true})
      # created user is always notified
      {:ok, _} = insert_outbox(user, activity)

      target = target_id |> Meta.find!() |> Meta.follow!()
      {:ok, _} = insert_outbox(target, activity)
    end)
  end

  defp insert_outbox(%User{} = user, activity) do
    Repo.insert(Users.Outbox.changeset(user, activity))
  end

  defp insert_outbox(%Community{} = community, activity) do
    Repo.transaction(fn ->
      {:ok, user} = Activities.fetch_user(activity)
      {:ok, _} = Repo.insert(Communities.Outbox.changeset(community, activity))

      if user.id != community.creator_id do
        {:ok, _} = insert_outbox(Communities.fetch_creator(community), activity)
      end
    end)
  end

  defp insert_outbox(%Collection{} = collection, activity) do
    Repo.transaction(fn ->
      {:ok, user} = Activities.fetch_user(activity)
      {:ok, _} = Repo.insert(Collections.Outbox.changeset(collection, activity))

      {:ok, comm} = Communities.fetch(collection.community_id)
      {:ok, _} = insert_outbox(comm, activity)

      if user.id != collection.creator_id do
        {:ok, _} = insert_outbox(Collections.fetch_creator(collection), activity)
      end
    end)
  end
end
