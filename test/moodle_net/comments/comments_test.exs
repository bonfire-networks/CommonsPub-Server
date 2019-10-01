# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNet.CommentsTest do
  use MoodleNet.DataCase, async: true

  import MoodleNet.Test.Faking
  alias MoodleNet.Common.Revision
  alias MoodleNet.Comments
  alias MoodleNet.Comments.CommentRevision
  alias MoodleNet.Meta
  alias MoodleNet.Test.Fake

  setup do
    parent = Meta.find!(fake_actor!().id)
    thread = fake_thread!(parent)
    {:ok, %{parent: parent, thread: thread}}
  end

  describe "fetch_thread" do
    test "fetches an existing thread", %{thread: thread} do
      assert {:ok, _} = Comments.fetch_thread(thread.id)
    end

    test "returns not found if the thread is missing" do
      assert {:error, %MoodleNet.Common.NotFoundError{}} = Comments.fetch_thread(Faker.UUID.v4())
    end
  end

  describe "create_thread" do
    test "creates a new thread with any parent", %{parent: parent} do
      attrs = Fake.thread()
      assert {:ok, thread} = Comments.create_thread(parent, attrs)
      assert thread.is_public == attrs.is_public
    end

    test "fails to create a thread with invalid attributes", %{parent: parent} do
      assert {:error, changeset} = Comments.create_thread(parent, %{})
      assert Keyword.get(changeset.errors, :is_public)
    end
  end

  describe "update_thread" do
    test "updates a thread with new attributes", %{parent: parent} do
      thread = fake_thread!(parent, %{is_public: true})
      assert {:ok, updated_thread} = Comments.update_thread(thread, %{is_public: false})
      assert updated_thread != thread
    end
  end

  describe "fetch_comment" do
    test "fetches an existing comment", %{thread: thread} do
      comment = fake_comment!(thread)
      assert {:ok, _} = Comments.fetch_comment(comment.id)
    end

    test "returns not found if the comment is missing" do
      assert {:error, %MoodleNet.Common.NotFoundError{}} = Comments.fetch_comment(Faker.UUID.v4())
    end
  end

  describe "create_comment" do
    test "creates a new comment with a thread parent", %{thread: thread} do
      attrs = Fake.comment()
      assert {:ok, comment} = Comments.create_comment(thread, attrs)
      assert comment.is_public == attrs.is_public
      assert comment.current.content == attrs.content
    end

    test "creates a revision for the comment", %{thread: thread} do
      comment = fake_comment!(thread)
      assert {:ok, comment} = Comments.fetch_comment(comment.id)
      assert comment = Repo.preload(comment, [:revisions, :current])
      assert [revision] = comment.revisions
      assert revision == comment.current
    end

    test "fails given invalid attributes", %{thread: thread} do
      assert {:error, changeset} = Comments.create_comment(thread, %{})
      assert Keyword.get(changeset.errors, :is_public)
      assert {:error, changeset} = Comments.create_comment(thread, %{is_public: false})
      assert Keyword.get(changeset.errors, :content)
    end
  end

  describe "update_comment" do
    test "updates a comment given valid attributes", %{thread: thread} do
      comment = fake_comment!(thread, %{is_public: true})

      assert {:ok, updated_comment} =
               Comments.update_comment(comment, Fake.comment(%{is_public: false}))

      assert updated_comment != comment
      refute updated_comment.is_public
    end

    test "creates a new revision for the update", %{thread: thread} do
      comment = fake_comment!(thread)
      assert {:ok, updated_comment} = Comments.update_comment(comment, Fake.comment())
      assert updated_comment.current != comment.current

      assert updated_comment = Revision.preload(CommentRevision, updated_comment)
      assert [latest_revision, oldest_revision] = updated_comment.revisions
      assert latest_revision != oldest_revision
      assert :gt = DateTime.compare(latest_revision.inserted_at, oldest_revision.inserted_at)
    end
  end
end
