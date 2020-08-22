# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Threads.Comments do
  import Ecto.Query
  alias MoodleNet.{Activities, Common, Feeds, Flags, Repo}
  alias MoodleNet.Access.NotPermittedError
  # alias MoodleNet.Collections.Collection
  # alias MoodleNet.Communities.Community
  # alias MoodleNet.FeedPublisher
  alias MoodleNet.Feeds.FeedActivities
  alias Pointers.Pointer
  # alias MoodleNet.Resources.Resource
  alias MoodleNet.Threads.{Comment, CommentsQueries, Thread}
  alias MoodleNet.Users.User
  alias MoodleNet.Workers.APPublishWorker

  def one(filters), do: Repo.single(CommentsQueries.query(Comment, filters))

  def many(filters \\ []), do: {:ok, Repo.all(CommentsQueries.query(Comment, filters))}

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

  def create(%User{} = creator, %Thread{} = thread, attrs, context \\ nil) when is_map(attrs) do
    Repo.transact_with(fn ->
      attrs = clean_and_prepare_tags(attrs)

      with {:ok, comment} <- insert(creator, thread, attrs),
           thread = preload_ctx(thread),
           act_attrs = %{verb: "created", is_local: comment.is_local},
           {:ok, activity} <- Activities.create(creator, comment, act_attrs),
           :ok <- publish(creator, thread, comment, activity, context),
           :ok <- ap_publish("create", comment) do
        comment = %{comment | thread: thread, creator: creator}
        index(comment)
        {:ok, comment}
      end
    end)
  end

  @doc """
  Create a comment in reply to another comment.

  Will fail with `NotPermittedError` if the parent thread is locked.
  """
  def create_reply(
        %User{} = creator,
        %Thread{} = thread,
        %Comment{} = reply_to,
        attrs
      ) do
    cond do
      thread.id != reply_to.thread_id ->
        {:error, NotPermittedError.new("create")}

      true ->
        attrs = Map.put(attrs, :reply_to_id, reply_to.id)

        create_reply(
          creator,
          thread,
          attrs
        )
    end
  end

  @doc """
  Create a comment within a thread.
  """

  def create_reply(
        %User{} = creator,
        %Thread{} = thread,
        attrs
      ) do
    cond do
      not is_nil(thread.locked_at) ->
        {:error, NotPermittedError.new("create")}

      true ->
        Repo.transact_with(fn ->
          attrs = clean_and_prepare_tags(attrs)

          with {:ok, comment} <- insert(creator, thread, attrs),
               {:ok, _tagged} = save_attached_tags(creator, comment, attrs),
               #  thread = preload_ctx(thread), #FIXME
               act_attrs = %{verb: "created", is_local: comment.is_local},
               {:ok, activity} <- Activities.create(creator, comment, act_attrs),
               #  thread = preload_ctx(thread),
               :ok <- publish(creator, thread, comment, activity, thread.context_id),
               :ok <- ap_publish("create", comment) do
            comment = %{comment | thread: thread, creator: creator}
            index(comment)
            {:ok, comment}
          end
        end)
    end
  end

  def clean_and_prepare_tags(attrs) do
    {content, mentions, hashtags} =
      CommonsPub.HTML.parse_input_and_tags(attrs.content, "text/markdown")

    IO.inspect(tagging: {content, mentions, hashtags})

    attrs
    |> Map.put(:content, content)
    |> Map.put(:mentions, mentions)
    |> Map.put(:hashtags, hashtags)
  end

  def save_attached_tags(creator, comment, attrs) do
    with {:ok, _taggable} <-
           CommonsPub.Tag.TagThings.thing_attach_tags(creator, comment, attrs.mentions) do
      # {:ok, MoodleNet.Repo.preload(comment, :tags)}
      {:ok, nil}
    end
  end

  defp insert(creator, thread, attrs) do
    Repo.insert(Comment.create_changeset(creator, thread, attrs))
  end

  def preload_ctx(%Thread{} = thread) do
    case thread.ctx do
      nil ->
        case thread.context do
          %Pointer{} = pointer ->
            follow_ctx(thread, pointer)

          nil ->
            thread

          _ ->
            preload_ctx(Repo.preload(thread, :context))
        end

      _ ->
        thread
    end
  end

  def follow_ctx(thread, pointer) do
    # FIXME, causes protocol Enumerable not implemented for %Pointers.Pointer
    context = MoodleNet.Meta.Pointers.follow!(pointer)
    %{thread | context: %{thread.context | pointed: context}}
  end

  @spec update(User.t(), Comment.t(), map) :: {:ok, Comment.t()} | {:error, Changeset.t()}
  def update(%User{}, %Comment{} = comment, attrs) do
    with {:ok, updated} <- Repo.update(Comment.update_changeset(comment, attrs)),
         :ok <- ap_publish("update", comment) do
      {:ok, updated}
    end
  end

  def update_by(%User{}, filters, updates) do
    Repo.update_all(CommentsQueries.query(Comment, filters), set: updates)
  end

  @spec soft_delete(User.t(), Comment.t()) :: {:ok, Comment.t()} | {:error, Changeset.t()}
  def soft_delete(%User{} = user, %Comment{} = comment) do
    Repo.transact_with(fn ->
      with {:ok, deleted} <- Common.soft_delete(comment),
           :ok <- chase_delete(user, comment.id),
           :ok <- ap_publish("delete", comment) do
        {:ok, deleted}
      end
    end)
  end

  def soft_delete_by(%User{} = user, filters) do
    with {:ok, _} <-
           Repo.transact_with(fn ->
             {_, ids} =
               update_by(user, [{:select, :id} | filters], deleted_at: DateTime.utc_now())

             with :ok <- chase_delete(user, ids) do
               ap_publish("delete", ids)
             end
           end),
         do: :ok
  end

  defp chase_delete(user, ids) do
    with :ok <- Flags.soft_delete_by(user, context: ids),
         :ok <- Activities.soft_delete_by(user, context: ids) do
      :ok
    end
  end

  defp publish(creator, thread, _comment, activity, nil) do
    feeds = [
      creator.outbox_id,
      thread.outbox_id,
      Feeds.instance_outbox_id()
    ]

    FeedActivities.publish(activity, feeds)
  end

  defp publish(creator, thread, _comment, activity, _context) do
    feeds =
      MoodleNet.Common.Contexts.context_feeds(thread.context.pointed) ++
        [
          creator.outbox_id,
          thread.outbox_id,
          Feeds.instance_outbox_id()
        ]

    FeedActivities.publish(activity, feeds)
  end

  defp ap_publish(verb, comments) when is_list(comments) do
    APPublishWorker.batch_enqueue(verb, comments)
    :ok
  end

  defp ap_publish(verb, %{is_local: true} = comment) do
    APPublishWorker.enqueue(verb, %{"context_id" => comment.id})
    :ok
  end

  defp ap_publish(_, _), do: :ok

  def indexing_object_format(comment) do
    # follower_count =
    #   case MoodleNet.Follows.FollowerCounts.one(context: comment.id) do
    #     {:ok, struct} -> struct.count
    #     {:error, _} -> nil
    #   end

    # icon = MoodleNet.Uploads.remote_url_from_id(comment.icon_id)
    # image = MoodleNet.Uploads.remote_url_from_id(comment.image_id)

    canonical_url = MoodleNet.ActivityPub.Utils.get_object_canonical_url(comment)

    %{
      "index_type" => "Comment",
      "id" => comment.id,
      "reply_to_id" => comment.reply_to_id,
      "thread" => %{
        "id" => comment.thread_id,
        "name" => comment.thread.name
      },
      "creator" => CommonsPub.Search.Indexer.format_creator(comment),
      "canonical_url" => canonical_url,
      # "followers" => %{
      #   "totalCount" => follower_count
      # },
      # "icon" => icon,
      # "image" => image,
      "name" => comment.name,
      "content" => comment.content,
      "published_at" => comment.published_at,
      # home instance of object:
      "index_instance" => URI.parse(canonical_url).host
    }
  end

  def index(comment) do
    object = indexing_object_format(comment)

    CommonsPub.Search.Indexer.index_object(object)

    :ok
  end
end
