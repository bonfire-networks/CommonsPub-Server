# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Threads do
  alias MoodleNet.{Common, Feeds, Repo}
  alias MoodleNet.Common.Contexts
  # alias MoodleNet.FeedPublisher
  alias MoodleNet.GraphQL.Fields
  alias MoodleNet.Threads.{Thread, Queries}
  alias MoodleNet.Users.User

  def cursor(:created), do: &[&1.id]
  def cursor(:followers), do: &[&1.follower_count, &1.id]

  def test_cursor(:created), do: &[&1["id"]]
  def test_cursor(:followers), do: &[&1["followerCount"], &1["id"]]

  def one(filters), do: Repo.single(Queries.query(Thread, filters))

  def many(filters \\ []), do: {:ok, Repo.all(Queries.query(Thread, filters))}

  @spec create(User.t, context :: any, map) :: {:ok, Thread.t} | {:error, Changeset.t}
  def create(%User{} = creator, context, attrs) do
    Repo.transact_with(fn ->
      with {:ok, feed} <- Feeds.create(),
           attrs = Map.put(attrs, :outbox_id, feed.id),
           {:ok, thread} <- insert(creator, context, attrs),
           # act_attrs = %{verb: "created", is_local: thread.is_local},
           # {:ok, activity} <- Activities.create(creator, thread, act_attrs),
           # :ok <- publish(creator, thread, context, :created),
           :ok <- ap_publish(creator, thread) do
        {:ok, thread}
      end
    end)
  end

  defp insert(creator, context, attrs) do
    Repo.insert(Thread.create_changeset(creator, context, attrs))
  end

  @doc """
  Update the attributes of a thread.
  """
  @spec update(Thread.t(), map) :: {:ok, Thread.t()} | {:error, Changeset.t()}
  def update(%Thread{} = thread, attrs) do
    Repo.transact_with(fn ->
      with {:ok, thread} <- Repo.update(Thread.update_changeset(thread, attrs)),
           # :ok <- publish(thread, :updated),
           :ok <- ap_publish(thread) do
        {:ok, thread}
      end
    end)
  end

  @spec soft_delete(Thread.t()) :: {:ok, Thread.t()} | {:error, Changeset.t()}
  def soft_delete(%Thread{} = thread) do
    Repo.transact_with(fn ->
      with {:ok, thread} <- Common.soft_delete(thread),
           # :ok <- publish(thread, :deleted),
           :ok <- ap_publish(thread) do
        {:ok, thread}
      end
    end)
  end

  def soft_delete_by(filters) do
    Queries.query(Thread)
    |> Queries.filter(filters)
    |> Repo.delete_all()
  end

  # defp context_feeds(%Resource{}=resource) do
  #   r = Repo.preload(resource, [collection: [:community]])
  #   [r.collection.outbox_id, r.collection.community.outbox_id]
  # end

  # defp context_feeds(%Collection{}=collection) do
  #   c = Repo.preload(collection, [:community])
  #   [c.outbox_id, c.community.outbox_id]
  # end

  # defp context_feeds(%Community{outbox_id: id}), do: [id]
  # defp context_feeds(%User{inbox_id: inbox, outbox_id: outbox}), do: [inbox, outbox]
  # defp context_feeds(_), do: []

  # defp publish(creator, thread, _context, :created) do
  #   with {:ok, activity} <- Activities.create(creator, thread, attrs) do
  #     FeedActivities.publish(feeds, activity)
  #   end
  # end
  # defp publish(thread, :updated), do: :ok
  # defp publish(thread, :deleted), do: :ok

  defp ap_publish(%{creator_id: id} = thread), do: ap_publish(%{id: id}, thread)

  # defp ap_publish(user, thread) do
  #   # There is no AP type for a thread yet
  #   FeedPublisher.publish(%{"context_id" => thread.id, "user_id" => user.id})
  # end
  defp ap_publish(_, _), do: :ok

end
