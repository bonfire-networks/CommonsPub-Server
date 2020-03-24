# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Threads.Comments do
  import Ecto.Query
  alias MoodleNet.{Activities, Common, Feeds, Repo}
  alias MoodleNet.Access.NotPermittedError
  alias MoodleNet.Common.Contexts
  alias MoodleNet.GraphQL.Fields
  alias MoodleNet.Collections.Collection
  alias MoodleNet.Communities.Community
  alias MoodleNet.Feeds.FeedActivities
  alias MoodleNet.Meta.{Pointer, Pointers}
  alias MoodleNet.Resources.Resource
  alias MoodleNet.Threads.{Comment, CommentsQueries, Thread}
  alias MoodleNet.Users.User

  def one(filters), do: Repo.single(CommentsQueries.query(Comment, filters))

  def many(filters \\ []), do: {:ok, Repo.all(CommentsQueries.query(Comment, filters))}

  def fields(group_fn, filters \\ [])
  when is_function(group_fn, 1) do
    ret =
      CommentsQueries.query(Comment, filters)
      |> Repo.all()
      |> Fields.new(group_fn)
    {:ok, ret}
  end

  @doc """
  Retrieves a Page of comments according to various filters

  Used by:
  * GraphQL resolver bulk resolution
  """
  def page(cursor_fn, page_opts, base_filters \\ [], data_filters \\ [], count_filters \\ [])
  def page(cursor_fn, page_opts, base_filters, data_filters, count_filters)
  when is_function(cursor_fn, 1) do
    Contexts.page CommentsQueries, Comment,
      cursor_fn, page_opts, base_filters, data_filters, count_filters
  end

  def pages(group_fn, cursor_fn, page_opts, base_filters \\ [], data_filters \\ [], count_filters \\ []) do
    Contexts.pages CommentsQueries, Comment,
      cursor_fn, group_fn, page_opts, base_filters, data_filters, count_filters
  end

  defp publish(creator, thread, comment, activity, :created) do
    feeds = context_feeds(thread.context.pointed) ++ [
      creator.outbox_id, thread.outbox_id, Feeds.instance_outbox_id(),
    ]
    with :ok <- FeedActivities.publish(activity, feeds) do
      ap_publish(comment.id, creator.id, comment.is_local)
    end
  end
  defp publish(comment, :updated) do
    ap_publish(comment.id, comment.creator_id, comment.is_local) # TODO: wrong if edited by admin
  end
  defp publish(comment, :deleted) do
    ap_publish(comment.id, comment.creator_id, comment.is_local) # TODO: wrong if edited by admin
  end

  defp ap_publish(context_id, user_id, true) do
    MoodleNet.FeedPublisher.publish(%{
      "context_id" => context_id,
      "user_id" => user_id,
    })
  end
  defp ap_publish(_, _, _), do: :ok

  defp context_feeds(%Resource{}=resource) do
    r = Repo.preload(resource, [collection: [:community]])
    [r.collection.outbox_id, r.collection.community.outbox_id]
  end

  defp context_feeds(%Collection{}=collection) do
    c = Repo.preload(collection, [:community])
    [c.outbox_id, c.community.outbox_id]
  end

  defp context_feeds(%Community{outbox_id: id}), do: [id]
  defp context_feeds(%User{inbox_id: inbox, outbox_id: outbox}), do: [inbox, outbox]
  defp context_feeds(_), do: []

  # Comments

  @doc """
  Return a list of public, non-deleted, unhidden comments contained in a thread.

  Ignores all comments if the parent thread has been deleted.
  """
  @spec list_comments_in_thread(Thread.t()) :: [Comment.t()]
  def list_comments_in_thread(%Thread{} = thread),
    do: Repo.all(list_comments_in_thread_q(thread.id))

  defp list_comments_in_thread_q(thread_id) do
    from(c in Comment,
      join: t in Thread,
      on: c.thread_id == t.id,
      where: t.id == ^thread_id,
      where: not is_nil(c.published_at),
      where: is_nil(c.hidden_at),
      where: is_nil(c.deleted_at),
      # allow for threads that are hidden because they can't be fetched unless
      # you use fetch_thread_private
      where: is_nil(t.deleted_at),
      order_by: [desc: c.updated_at]
    )
  end

  @doc """
  Return all public, non-deleted, unhidden comments for a user.

  Will fetch comments regardless of whether the user has been deleted.
  """
  @spec list_comments_for_user(User.t()) :: [Comment.t()]
  def list_comments_for_user(%User{} = user),
    do: Repo.all(list_comments_for_user_q(user.id))

  defp list_comments_for_user_q(user_id) do
    from(c in Comment,
      join: u in User,
      on: c.creator_id == u.id,
      where: u.id == ^user_id,
      where: not is_nil(c.published_at),
      where: is_nil(c.hidden_at),
      where: is_nil(c.deleted_at)
    )
  end

  @spec create(User.t(), Thread.t(), map) :: {:ok, Comment.t()} | {:error, Changeset.t()}
  def create(%User{} = creator, %Thread{} = thread, attrs) when is_map(attrs) do
    Repo.transact_with(fn ->
      with {:ok, comment} <- insert(thread, creator, attrs),
           thread = preload_ctx(thread),
           act_attrs = %{verb: "created", is_local: comment.is_local},
           {:ok, activity} <- Activities.create(creator, comment, act_attrs),
           :ok <- publish(creator, thread, comment, activity, :created) do
        {:ok, %{ comment | thread: thread }}
      end
    end)
  end

  @doc """
  Create a comment in reply to another comment.

  Will fail with `NotPermittedError` if the parent thread is locked.
  """
  @spec create_reply(User.t(), Thread.t(), Comment.t(), map) ::
    {:ok, Comment.t()} | {:error, Changeset.t()} | {:error, NotPermittedError.t()}

  def create_reply(
    %User{} = creator,
    %Thread{} = thread,
    %Comment{} = reply_to,
    attrs
  ) do
    cond do
      not is_nil(thread.locked_at) -> {:error, NotPermittedError.new("create")}
      thread.id != reply_to.thread_id -> {:error, NotPermittedError.new("create")}
      true ->
        attrs = Map.put(attrs, :reply_to_id, reply_to.id)
        Repo.transact_with(fn ->
          with {:ok, comment} <- insert(thread, creator, attrs),
               thread = preload_ctx(thread),
               act_attrs = %{verb: "created", is_local: comment.is_local},
               {:ok, activity} <- Activities.create(creator, comment, act_attrs),
               thread = preload_ctx(thread),
               :ok <- publish(creator, thread, comment, activity, :created) do
            {:ok, comment}
          end
        end)
    end
  end

  defp insert(thread, creator, attrs) do
    Repo.insert(Comment.create_changeset(creator, thread, attrs))
  end

  def preload_ctx(%Thread{}=thread) do
    case thread.ctx do
      nil ->
        case thread.context do
          %Pointer{}=pointer ->
            context = Pointers.follow!(pointer)
            %{ thread | context: %{ thread.context | pointed: context }}
          _ -> preload_ctx(Repo.preload(thread, :context))
        end
      _ -> thread
    end
  end

  @spec update(Comment.t(), map) :: {:ok, Comment.t()} | {:error, Changeset.t()}

  def update(%Comment{is_local: false} = comment, attrs) do
    Repo.update(Comment.update_changeset(comment, attrs))
  end

  def update(%Comment{is_local: true} = comment, attrs) do
    with {:ok, updated} <- Repo.update(Comment.update_changeset(comment, attrs)),
         :ok <- publish(comment, :updated) do
      {:ok, updated}
    end
  end

  @spec soft_delete(Comment.t()) :: {:ok, Comment.t()} | {:error, Changeset.t()}
  def soft_delete(%Comment{is_local: false} = comment) do
    Common.soft_delete(comment)
  end

  def soft_delete(%Comment{is_local: true} = comment) do
    with {:ok, deleted} <- Common.soft_delete(comment),
         :ok <- publish(comment, :deleted) do
      {:ok, deleted}
    end
  end

end
