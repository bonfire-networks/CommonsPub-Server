# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Follows do
  alias MoodleNet.{Activities, Common, GraphQL, Repo}
  alias MoodleNet.Feeds.{FeedActivities, FeedSubscriptions}
  alias MoodleNet.Follows.{
    AlreadyFollowingError,
    Follow,
    Queries,
  }
  alias MoodleNet.Meta.{Pointer, Pointers}
  alias MoodleNet.Users.{LocalUser, User}
  alias MoodleNet.Workers.APPublishWorker
  alias Ecto.Changeset

  def one(filters), do: Repo.single(Queries.query(Follow, filters))

  def many(filters \\ []), do: {:ok, Repo.all(Queries.query(Follow, filters))}

  @type create_opt :: {:publish, bool} | {:federate, bool}
  @type create_opts :: [create_opt]

  @spec create(User.t(), any, map) :: {:ok, Follow.t()} | {:error, Changeset.t()}
  @spec create(User.t(), any, map, create_opts) :: {:ok, Follow.t()} | {:error, Changeset.t()}

  def create(follower, followed, fields, opts \\ [])
  def create(%User{} = follower, %Pointer{}=followed, %{}=fields, opts) do
    create(follower, Pointers.follow!(followed), fields, opts)
  end
  def create(%User{} = follower, %{outbox_id: _}=followed, fields, _opts) do
    if followed.__struct__ in valid_contexts() do
      Repo.transact_with(fn ->
        case one([deleted: false, creator: follower.id, context: followed.id]) do
          {:ok, _} ->
            {:error, AlreadyFollowingError.new("user")}

          _ ->
            with {:ok, follow} <- insert(follower, followed, fields),
                 :ok <- subscribe(follower, followed, follow),
                 :ok <- publish(follower, followed, follow, :created),
                 :ok <- ap_publish("create", follow) do
              {:ok, %{follow | ctx: followed}}
            end
        end
      end)
    else
      GraphQL.not_permitted()
    end
  end

  defp insert(follower, followed, fields) do
    Repo.insert(Follow.create_changeset(follower, followed, fields))
  end

  defp publish(creator, followed, %Follow{} = follow, :created) do
    attrs = %{verb: "created", is_local: follow.is_local}
    with {:ok, activity} <- Activities.create(creator, follow, attrs) do
      FeedActivities.publish(activity, [creator.outbox_id, followed.outbox_id])
    end
  end

  defp publish(_follow, :updated) do # TODO
    :ok
  end

  defp publish(_follow, :deleted) do # TODO
    :ok
  end

  defp ap_publish(verb, %Follow{is_local: true} = follow) do
    APPublishWorker.enqueue(verb, %{"context_id" => follow.id})
    :ok
  end

  defp ap_publish(_, _), do: :ok

  @spec update(Follow.t(), map) :: {:ok, Follow.t()} | {:error, Changeset.t()}
  def update(%Follow{} = follow, fields) do
    Repo.transact_with(fn ->
      with {:ok, follow} <- Repo.update(Follow.update_changeset(follow, fields)),
           :ok <- publish(follow, :updated),
           :ok <- ap_publish("update", follow) do
        {:ok, follow}
      end
    end)
  end

  @spec soft_delete(Follow.t()) :: {:ok, Follow.t()} | {:error, Changeset.t()}
  def soft_delete(%Follow{} = follow) do
    Repo.transact_with(fn ->
      with {:ok, _} <- unsubscribe(follow),
           {:ok, follow} <- Common.soft_delete(follow),
           :ok <- publish(follow, :deleted),
           :ok <- ap_publish("delete", follow) do
        {:ok, follow}
      end
    end)
  end

  def update_by(filters, updates), do: Repo.update_all(Queries.query(Follow, filters), updates)

  # we only maintain subscriptions for local users
  defp subscribe(%User{local_user: %LocalUser{}}=follower, %{outbox_id: outbox_id}, %Follow{muted_at: nil})
  when is_binary(outbox_id) do
    case FeedSubscriptions.one(deleted: false, subscriber: follower.id, feed: outbox_id) do
      {:ok, _} -> :ok
      _ ->
        with {:ok, _} <- FeedSubscriptions.create(follower, outbox_id, %{is_active: true}), do: :ok
    end
  end
  defp subscribe(_,_,_), do: :ok

  defp unsubscribe(%{creator_id: creator_id, is_local: true, muted_at: nil}=follow) do
    context = Pointers.follow!(Repo.preload(follow, :context).context)
    case FeedSubscriptions.one(deleted: false, subscriber: creator_id, feed: context.outbox_id) do
      {:ok, sub} -> Common.soft_delete(sub)
      _ -> {:ok, []} # shouldn't be here
    end
  end

  defp unsubscribe(_), do: {:ok, []}

  def valid_contexts() do
    Application.fetch_env!(:moodle_net, __MODULE__)
    |> Keyword.fetch!(:valid_contexts)
  end

end
