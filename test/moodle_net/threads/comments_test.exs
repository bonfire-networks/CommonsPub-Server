# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Threads.CommentsTest do
  use MoodleNet.DataCase, async: true
  use Oban.Testing, repo: MoodleNet.Repo

  import MoodleNet.Test.Faking
  alias MoodleNet.Access.NotPermittedError
  alias MoodleNet.Common.NotFoundError
  alias MoodleNet.Resources.Resource
  alias MoodleNet.Users.User
  alias MoodleNet.Threads
  alias MoodleNet.Threads.{Comments, Thread}
  alias MoodleNet.Test.Fake

  setup do
    user = fake_user!()
    comm = fake_community!(user)
    coll = fake_collection!(user, comm)
    resource = fake_resource!(user, coll)
    thread = fake_thread!(user, resource)
    {:ok, %{user: user, parent: resource, thread: thread}}
  end

  describe "Threads.many/1" do
    test "returns a list of unhidden threads", context do
      all =
        for _ <- 1..4 do
          fake_thread!(context.user, context.parent)
        end ++ [context.thread]

      hidden = Enum.filter(all, & &1.is_hidden)
      {:ok, fetched} = Threads.many()

      assert Enum.count(all) - Enum.count(hidden) == Enum.count(fetched)

      for thread <- fetched do
        assert thread.follower_count
      end
    end

    test "returns all threads", context do
      all =
        for _ <- 1..4 do
          fake_thread!(context.user, context.parent)
        end ++ [context.thread]

      {:ok, fetched} = Threads.many(:private)
      assert Enum.count(all) == Enum.count(fetched)

      for thread <- fetched do
        assert thread.follower_count
      end
    end
  end

  describe "Threads.one/1" do
    test "fetches an existing thread", %{thread: thread} do
      assert {:ok, thread} = Threads.update(thread, %{is_hidden: false})
      assert {:ok, _} = Threads.one(id: thread.id)
    end

    test "returns not found if the thread is hidden", %{thread: thread} do
      assert {:ok, thread} = Threads.update(thread, %{is_hidden: true})
      assert {:error, %NotFoundError{}} = Threads.one([:hidden, id: thread.id])
    end

    test "returns not found if the thread is deleted", %{thread: thread} do
      assert {:ok, thread} = Threads.soft_delete(thread)
      assert {:error, %NotFoundError{}} = Threads.one([:deleted, id: thread.id])
    end

    test "returns not found if the thread is missing" do
      assert {:error, %NotFoundError{}} = Threads.one(id: Fake.ulid())
    end

    test "fetches any thread", %{thread: thread} do
      assert {:ok, thread} = Threads.update(thread, %{is_hidden: false})
      assert {:ok, thread} = Threads.one([:private, id: thread.id])
      assert {:ok, thread} = Threads.update(thread, %{is_hidden: true})
      assert {:ok, thread} = Threads.one([:private, id: thread.id])
      assert {:ok, thread} = Threads.soft_delete(thread)
      assert {:ok, _} = Threads.one([:private, id: thread.id])
    end
  end

  describe "fetch_thread_creator" do
    test "returns the creator of a thread", context do
      assert {:ok, creator} = Comments.fetch_thread_creator(context.thread)
      assert creator.id == context.user.id
    end
  end

  describe "fetch_thread_context" do
    test "returns the context of a thread", context do
      assert {:ok, %Resource{} = resource} = Comments.fetch_thread_context(context.thread)
      assert resource.id == context.parent.id
    end
  end

  describe "Threads.create/3" do
    test "creates a new thread with any parent", %{user: creator, parent: parent} do
      attrs = Fake.thread()
      assert {:ok, thread} = Threads.create(creator, parent, attrs)
      assert thread.canonical_url == attrs[:canonical_url]
    end

    test "fails to create a thread with invalid attributes", %{user: creator, parent: parent} do
      assert {:error, changeset} = Threads.create(creator, parent, %{})
      assert Keyword.get(changeset.errors, :is_local)
    end
  end

  describe "Threads.update/2" do
    test "updates a thread with new attributes", %{user: creator, parent: parent} do
      thread = fake_thread!(creator, parent)
      attrs = Fake.thread()
      assert {:ok, updated_thread} = Threads.update(thread, attrs)
      assert updated_thread != thread
      assert updated_thread.canonical_url == attrs.canonical_url
    end
  end

  describe "Threads.soft_delete/1" do
    test "changes the deleted date for a thread", %{thread: thread} do
      refute thread.deleted_at
      assert {:ok, thread} = Threads.soft_delete(thread)
      assert thread.deleted_at
    end
  end

  describe "Comments.list_comments_in_thread/1" do
    test "returns a list of comments in a thread", context do
      all =
        for _ <- 1..5 do
          user = fake_user!()
          fake_comment!(user, context.thread, %{is_hidden: false, is_public: true})
        end

      fetched = Comments.list_comments_in_thread(context.thread)

      assert Enum.count(all) == Enum.count(fetched)
    end

    test "excludes unpublished comments", context do
      all =
        for _ <- 1..5 do
          user = fake_user!()
          fake_comment!(user, context.thread, %{is_hidden: false})
        end

      unpublished =
        Enum.reduce(all, [], fn comment, acc ->
          if Fake.bool() do
            {:ok, comment} = Comments.update(comment, %{is_public: false})
            [comment | acc]
          else
            acc
          end
        end)

      fetched = Comments.list_comments_in_thread(context.thread)

      assert Enum.count(all) - Enum.count(unpublished) == Enum.count(fetched)
    end

    test "excludes hidden comments", context do
      all =
        for _ <- 1..5 do
          user = fake_user!()
          fake_comment!(user, context.thread)
        end

      hidden = Enum.filter(all, & &1.hidden_at)
      fetched = Comments.list_comments_in_thread(context.thread)

      assert Enum.count(all) - Enum.count(hidden) == Enum.count(fetched)
    end

    test "excludes deleted comments", context do
      all =
        for _ <- 1..5 do
          user = fake_user!()
          fake_comment!(user, context.thread, %{is_hidden: false})
        end

      deleted =
        Enum.reduce(all, [], fn comment, acc ->
          if Fake.bool() do
            {:ok, comment} = Comments.soft_delete(comment)
            [comment | acc]
          else
            acc
          end
        end)

      fetched = Comments.list_comments_in_thread(context.thread)

      assert Enum.count(all) - Enum.count(deleted) == Enum.count(fetched)
    end

    test "ignores comments with a deleted parent thread", context do
      fake_comment!(context.user, context.thread)
      assert {:ok, thread} = Threads.soft_delete(context.thread)
      assert Enum.empty?(Comments.list_comments_in_thread(thread))
    end
  end

  describe "Comments.list_comments_for_user/1" do
    test "lists comments for a user", context do
      all =
        for _ <- 1..5 do
          fake_comment!(context.user, context.thread, %{is_hidden: false})
        end

      fetched = Comments.list_comments_for_user(context.user)
      assert Enum.count(all) == Enum.count(fetched)
    end

    test "excludes unpublished comments", context do
      all =
        for _ <- 1..5 do
          fake_comment!(context.user, context.thread, %{is_hidden: false})
        end

      unpublished =
        Enum.reduce(all, [], fn comment, acc ->
          if Fake.bool() do
            {:ok, comment} = Comments.update(comment, %{is_public: false})
            [comment | acc]
          else
            acc
          end
        end)

      fetched = Comments.list_comments_for_user(context.user)

      assert Enum.count(all) - Enum.count(unpublished) == Enum.count(fetched)
    end

    test "excludes hidden comments", context do
      all = for _ <- 1..5, do: fake_comment!(context.user, context.thread)
      hidden = Enum.filter(all, & &1.hidden_at)
      fetched = Comments.list_comments_for_user(context.user)

      assert Enum.count(all) - Enum.count(hidden) == Enum.count(fetched)
    end

    test "excludes deleted comments", context do
      all =
        for _ <- 1..5 do
          fake_comment!(context.user, context.thread, %{is_hidden: false})
        end

      deleted =
        Enum.reduce(all, [], fn comment, acc ->
          if Fake.bool() do
            {:ok, comment} = Comments.soft_delete(comment)
            [comment | acc]
          else
            acc
          end
        end)

      fetched = Comments.list_comments_for_user(context.user)

      assert Enum.count(all) - Enum.count(deleted) == Enum.count(fetched)
    end
  end

  describe "Comments.one/1" do
    test "fetches a comment by ID", context do
      thread = fake_thread!(context.user, context.parent, %{is_hidden: false})
      comment = fake_comment!(context.user, thread, %{is_hidden: false})
      assert {:ok, _} = Comments.one(id: comment.id)
    end

    test "returns not found if comment is hidden", context do
      comment = fake_comment!(context.user, context.thread, %{is_hidden: true})
      assert {:error, %NotFoundError{}} = Comments.one([:hidden, id: comment.id])
    end

    test "returns not found if the comment is unpublished", context do
      comment = fake_comment!(context.user, context.thread, %{is_hidden: false})
      assert {:ok, comment} = Comments.update(comment, %{is_public: false})
      assert {:error, %NotFoundError{}} = Comments.one(id: comment.id)
    end

    test "returns not found if the comment is deleted", context do
      comment = fake_comment!(context.user, context.thread, %{is_hidden: false})
      assert {:ok, comment} = Comments.soft_delete(comment)
      assert {:error, %NotFoundError{}} = Comments.one([:deleted, id: comment.id])
    end

    test "returns not found if the parent thread is hidden", context do
      thread = fake_thread!(context.user, context.parent, %{is_hidden: true})
      comment = fake_comment!(context.user, thread, %{is_hidden: false})
      assert {:error, %NotFoundError{}} = Comments.one([:hidden, id: comment.id])
    end

    test "returns not found if the parent thread is deleted", context do
      comment = fake_comment!(context.user, context.thread, %{is_hidden: false})
      assert {:ok, _} = Comments.soft_delete(context.thread)
      assert {:error, %NotFoundError{}} = Comments.one([:deleted, id: comment.id])
    end
  end

  describe "fetch_comment_creator" do
    test "fetches the creator of a comment", context do
      comment = fake_comment!(context.user, context.thread)
      assert {:ok, %User{} = creator} = Comments.fetch_comment_creator(comment)
      assert creator.id == context.user.id
    end
  end

  describe "fetch_comment_thread" do
    test "fetches the parent thread of a comment", context do
      thread = fake_thread!(context.user, context.parent, %{is_hidden: false, is_locked: false})
      comment = fake_comment!(context.user, thread)
      assert {:ok, %Thread{} = fetched_thread} = Comments.fetch_comment_thread(comment)
      assert fetched_thread.id == thread.id
    end
  end

  describe "fetch_comment_reply_to" do
    test "returns the reply for a comment", context do
      thread = fake_thread!(context.user, context.parent, %{is_hidden: false, is_locked: false})
      in_reply = fake_comment!(context.user, thread, %{is_hidden: false})

      assert {:ok, comment} =
        Comments.create_comment_reply(context.user, thread, in_reply, Fake.comment())

      assert {:ok, fetched_reply_to} = Comments.fetch_comment_reply_to(comment)
      assert fetched_reply_to.id == in_reply.id
    end

    test "returns not found if there is no reply to set", context do
      thread = fake_thread!(context.user, context.parent, %{is_hidden: false, is_locked: false})
      comment = fake_comment!(context.user, thread, %{is_hidden: false})
      assert {:error, %NotFoundError{}} = Comments.fetch_comment_reply_to(comment)
    end
  end

  describe "Comments.create/3" do
    test "creates a new comment with a thread parent", %{user: creator, thread: thread} do
      attrs = Fake.comment()
      assert {:ok, comment} = Comments.create(creator, thread, attrs)
      assert comment.canonical_url == attrs.canonical_url
      assert comment.content == attrs.content
      assert comment.is_hidden == attrs.is_hidden
      assert comment.is_local == attrs.is_local
    end

    test "fails given invalid attributes", %{user: creator, thread: thread} do
      assert {:error, changeset} = Comments.create(creator, thread, %{is_public: false})

      assert Keyword.get(changeset.errors, :content)
    end
  end

  describe "Comments.create_reply/4" do
    test "creates a new comment replying to another", context do
      thread = fake_thread!(context.user, context.parent, %{is_locked: false})
      reply_to = fake_comment!(context.user, thread)

      assert {:ok, comment} =
               Comments.create_reply(
                 context.user,
                 thread,
                 reply_to,
                 Fake.comment()
               )

      assert comment.reply_to_id == reply_to.id
    end

    test "fails if the parent thread is locked", context do
      thread = fake_thread!(context.user, context.parent, %{is_locked: true})
      reply_to = fake_comment!(context.user, thread)

      assert {:error, %NotPermittedError{}} =
        Comments.create_reply(context.user, thread, reply_to, Fake.comment())
    end
  end

  describe "Comments.update/2" do
    test "updates a comment given valid attributes", %{user: creator, thread: thread} do
      comment = fake_comment!(creator, thread)

      attrs = Fake.comment()
      assert {:ok, updated_comment} = Comments.update(comment, attrs)
      assert updated_comment != comment
      assert updated_comment.canonical_url == attrs.canonical_url
      assert updated_comment.content == attrs.content
    end
  end

  describe "Comments.soft_delete/1" do
    test "changes the deletion date of the comment", context do
      comment = fake_comment!(context.user, context.thread)
      refute comment.deleted_at
      assert {:ok, comment} = Comments.soft_delete(comment)
      assert comment.deleted_at
    end
  end
end
