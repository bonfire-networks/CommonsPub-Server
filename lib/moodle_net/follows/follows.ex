# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Follows do
  alias MoodleNet.{Activities, Common, GraphQL, Repo}
  alias MoodleNet.Common.Contexts
  alias MoodleNet.GraphQL.Fields
  alias MoodleNet.Feeds.{FeedActivities, FeedSubscriptions}
  alias MoodleNet.Follows.{
    AlreadyFollowingError,
    Follow,
    Queries,
  }
  alias MoodleNet.Meta.{Pointer, Pointers}
  alias MoodleNet.Users.{LocalUser, User}
  alias Ecto.Changeset

  def one(filters), do: Repo.single(Queries.query(Follow, filters))

  def many(filters \\ []), do: {:ok, Repo.all(Queries.query(Follow, filters))}

  def fields(group_fn, filters \\ [])
  when is_function(group_fn, 1) do
    {:ok, fields} = many(filters)
    {:ok, Fields.new(fields, group_fn)}
  end

  @doc """
  Retrieves an Pages of follows according to various filters

  Used by:
  * GraphQL resolver bulk resolution
  """
  def page(cursor_fn, page_opts, base_filters \\ [], data_filters \\ [], count_filters \\ [])
  def page(cursor_fn, page_opts, base_filters, data_filters, count_filters) do
    Contexts.page Queries, Follow,
      cursor_fn, page_opts, base_filters, data_filters, count_filters
  end

  def pages(group_fn, cursor_fn, page_opts, base_filters \\ [], data_filters \\ [], count_filters \\ []) do
    Contexts.pages Queries, Follow,
      cursor_fn, group_fn, page_opts, base_filters, data_filters, count_filters

  end

  @type create_opt :: {:publish, bool} | {:federate, bool}
  @type create_opts :: [create_opt]

  @spec create(User.t(), any, map) :: {:ok, Follow.t()} | {:error, Changeset.t()}
  @spec create(User.t(), any, map, create_opts) :: {:ok, Follow.t()} | {:error, Changeset.t()}

  def create(follower, followed, fields, opts \\ [])
  def create(%User{} = follower, %Pointer{}=followed, %{}=fields, opts) do
    create(follower, Pointers.follow!(followed), fields, opts)
  end
  def create(%User{} = follower, %{outbox_id: _}=followed, fields, opts) do
    if followed.__struct__ in valid_contexts() do
      Repo.transact_with(fn ->
        case one([:deleted, creator_id: follower.id, context_id: followed.id]) do
          {:ok, _} ->
            {:error, AlreadyFollowingError.new("user")}

          _ ->
            with {:ok, follow} <- insert(follower, followed, fields),
                 :ok <- subscribe(follower, followed, follow),
                 :ok <- publish(follower, followed, follow, :created, opts),
                 :ok <- federate(follow, opts) do
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

  defp publish(creator, followed, %Follow{} = follow, :created, opts) do
    if Keyword.get(opts, :publish, true) do
      attrs = %{verb: "created", is_local: follow.is_local}
      with {:ok, activity} <- Activities.create(creator, follow, attrs) do
        FeedActivities.publish(activity, [creator.outbox_id, followed.outbox_id])
      end
    else
      :ok
    end
  end

  defp federate(follow, opts \\ [])
  defp federate(%Follow{is_local: true} = follow, opts) do
    if Keyword.get(opts, :federate, true) do
      MoodleNet.FeedPublisher.publish(%{
        "context_id" => follow.context_id,
        "user_id" => follow.creator_id,
      })
    else
      :ok
    end
  end
  defp federate(_, _), do: :ok

  @spec update(Follow.t(), map) :: {:ok, Follow.t()} | {:error, Changeset.t()}
  def update(%Follow{} = follow, fields) do
    Repo.transact_with(fn ->
      follow
      |> Follow.update_changeset(fields)
      |> Repo.update()
    end)
  end

  @spec undo(Follow.t()) :: {:ok, Follow.t()} | {:error, Changeset.t()}
  def undo(%Follow{is_local: true} = follow) do
    Repo.transact_with(fn ->
      with {:ok, _} <- unsubscribe(follow),
           {:ok, follow} <- Common.soft_delete(follow),
           :ok <- federate(follow) do
        {:ok, follow}
      end
    end)
  end

  def undo(%Follow{is_local: false} = follow) do
    Common.soft_delete(follow)
  end

  # we only maintain subscriptions for local users
  defp subscribe(%User{local_user: %LocalUser{}}=follower, %{outbox_id: outbox_id}, %Follow{muted_at: nil})
  when is_binary(outbox_id) do
    case FeedSubscriptions.one([:deleted, subscriber_id: follower.id, feed_id: outbox_id]) do
      {:ok, _} -> :ok
      _ ->
        with {:ok, _} <- FeedSubscriptions.create(follower, outbox_id, %{is_active: true}), do: :ok
    end
  end
  defp subscribe(_,_,_), do: :ok

  defp unsubscribe(%{creator_id: creator_id, is_local: true, muted_at: nil}=follow) do
    context = Pointers.follow!(Repo.preload(follow, :context).context)
    case FeedSubscriptions.one([:deleted, subscriber_id: creator_id, feed_id: context.outbox_id]) do
      {:ok, sub} -> Common.soft_delete(sub)
      _ -> {:ok, []} # shouldn't be here
    end
  end

  def valid_contexts() do
    Application.fetch_env!(:moodle_net, __MODULE__)
    |> Keyword.fetch!(:valid_contexts)
  end

end
