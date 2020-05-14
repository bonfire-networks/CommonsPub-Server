# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Threads do
  alias MoodleNet.{Common, Feeds, Follows, Repo}
  # alias MoodleNet.FeedPublisher
  alias MoodleNet.Threads.{Comments, Thread, Queries}
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
           {:ok, thread} <- insert(creator, context, attrs) do
           # act_attrs = %{verb: "created", is_local: thread.is_local},
           # {:ok, activity} <- Activities.create(creator, thread, act_attrs),
           # :ok <- publish(creator, thread, context, :created),
           # :ok <- ap_publish(creator, thread) do
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
  @spec update(User.t(), Thread.t(), map) :: {:ok, Thread.t()} | {:error, Changeset.t()}
  def update(%User{}, %Thread{} = thread, attrs) do
    Repo.transact_with(fn ->
      with {:ok, thread} <- Repo.update(Thread.update_changeset(thread, attrs)) do
           # :ok <- publish(thread, :updated),
           # :ok <- ap_publish(thread) do
        {:ok, thread}
      end
    end)
  end

  def update_by(%User{}, filters, updates) do
    Repo.update_all(Queries.query(Thread, filters), set: updates)
  end

  @spec soft_delete(User.t(), Thread.t()) :: {:ok, Thread.t()} | {:error, Changeset.t()}
  def soft_delete(%User{}=user, %Thread{} = thread) do
    Repo.transact_with(fn ->
      with {:ok, thread} <- Common.soft_delete(thread),
           :ok <- chase_delete(user, thread.id) do
        {:ok, thread}
      end
    end)
  end

  def soft_delete_by(%User{}=user, filters) do
    with {:ok, _} <-
      Repo.transact_with(fn ->
        {_, ids} = update_by(user, [{:select, :id} | filters], deleted_at: DateTime.utc_now())
        chase_delete(user, ids)
      end), do: :ok
  end

  defp chase_delete(user, ids) do
    with :ok <- Comments.soft_delete_by(user, thread: ids) do
      Follows.soft_delete_by(user, context: ids)
    end
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

end
