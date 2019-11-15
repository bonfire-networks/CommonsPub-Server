# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.CommentsTest do
  use MoodleNet.DataCase, async: true

  import MoodleNet.Test.Faking
  alias MoodleNet.Common.NotFoundError
  alias MoodleNet.Comments
  alias MoodleNet.Test.Fake

  setup do
    user = fake_user!()
    comm = fake_community!(user)
    coll = fake_collection!(user, comm)
    resource = fake_resource!(user, coll)
    thread = fake_thread!(user, resource)
    {:ok, %{user: user, parent: resource, thread: thread}}
  end

  describe "list_threads" do
    test "returns a list of unhidden threads", context do
      all = for _ <- 1..4 do
        fake_thread!(context.user, context.parent)
      end ++ [context.thread]
      hidden = Enum.filter(all, &(&1.is_hidden))
      fetched = Comments.list_threads()

      assert Enum.count(all) - Enum.count(hidden) == Enum.count(fetched)

      for thread <- fetched do
        assert thread.follower_count
      end
    end
  end

  describe "list_threads_private" do
    test "returns all threads", context do
      all = for _ <- 1..4 do
        fake_thread!(context.user, context.parent)
      end ++ [context.thread]
      fetched = Comments.list_threads_private()
      assert Enum.count(all) == Enum.count(fetched)

      for thread <- fetched do
        assert thread.follower_count
      end
    end
  end

  describe "fetch_thread" do
    test "fetches an existing thread", %{thread: thread} do
      assert {:ok, thread} = Comments.update_thread(thread, %{is_hidden: false})
      assert {:ok, _} = Comments.fetch_thread(thread.id)
    end

    test "returns not found if the thread is hidden", %{thread: thread} do
      assert {:ok, thread} = Comments.update_thread(thread, %{is_hidden: true})
      assert {:error, %NotFoundError{}} = Comments.fetch_thread(thread.id)
    end

    test "returns not found if the thread is deleted", %{thread: thread} do
      assert {:ok, thread} = Comments.soft_delete_thread(thread)
      assert {:error, %NotFoundError{}} = Comments.fetch_thread(thread.id)
    end

    test "returns not found if the thread is missing" do
      assert {:error, %NotFoundError{}} = Comments.fetch_thread(Faker.UUID.v4())
    end
  end

  describe "fetch_thread_private" do
    test "fetches any thread", %{thread: thread} do
      assert {:ok, thread} = Comments.update_thread(thread, %{is_hidden: false})
      assert {:ok, thread} = Comments.fetch_thread_private(thread.id)
      assert {:ok, thread} = Comments.update_thread(thread, %{is_hidden: true})
      assert {:ok, thread} = Comments.fetch_thread_private(thread.id)
      assert {:ok, thread} = Comments.soft_delete_thread(thread)
      assert {:ok, _} = Comments.fetch_thread_private(thread.id)
    end
  end

  describe "create_thread" do
    test "creates a new thread with any parent", %{user: creator, parent: parent} do
      attrs = Fake.thread()
      assert {:ok, thread} = Comments.create_thread(parent, creator, attrs)
      assert thread.canonical_url == attrs[:canonical_url]
    end

    test "fails to create a thread with invalid attributes", %{user: creator, parent: parent} do
      assert {:error, changeset} = Comments.create_thread(parent, creator, %{})
      assert Keyword.get(changeset.errors, :is_locked)
      assert Keyword.get(changeset.errors, :is_local)
    end
  end

  describe "update_thread" do
    test "updates a thread with new attributes", %{user: creator, parent: parent} do
      thread = fake_thread!(creator, parent)
      attrs = Fake.thread()
      assert {:ok, updated_thread} = Comments.update_thread(thread, attrs)
      assert updated_thread != thread
      assert updated_thread.canonical_url == attrs.canonical_url
    end
  end

  describe "soft_delete_thread" do
    test "changes the deleted date for a thread", %{thread: thread} do
      assert {:ok, thread} = Comments.soft_delete_thread(thread)
      assert thread.deleted_at
    end
  end

  describe "fetch_comment" do
    test "fetches an existing comment", %{user: creator, thread: thread} do
      comment = fake_comment!(creator, thread)
      assert {:ok, _} = Comments.fetch_comment(comment.id)
    end

    test "returns not found if the comment is missing" do
      assert {:error, %MoodleNet.Common.NotFoundError{}} = Comments.fetch_comment(Faker.UUID.v4())
    end
  end

  describe "create_comment" do
    test "creates a new comment with a thread parent", %{user: creator, thread: thread} do
      attrs = Fake.comment()
      assert {:ok, comment} = Comments.create_comment(thread, creator, attrs)
      assert comment.canonical_url == attrs.canonical_url
      assert comment.content == attrs.content
      assert comment.is_hidden == attrs.is_hidden
      assert comment.is_local == attrs.is_local
    end

    test "fails given invalid attributes", %{user: creator, thread: thread} do
      assert {:error, changeset} =
               Comments.create_comment(thread, creator, %{is_public: false})

      assert Keyword.get(changeset.errors, :content)
    end
  end

  describe "update_comment" do
    test "updates a comment given valid attributes", %{user: creator, thread: thread} do
      comment = fake_comment!(creator, thread)

      attrs = Fake.comment()
      assert {:ok, updated_comment} = Comments.update_comment(comment, attrs)
      assert updated_comment != comment
      assert updated_comment.canonical_url == attrs.canonical_url
      assert updated_comment.content == attrs.content
    end
  end
end
