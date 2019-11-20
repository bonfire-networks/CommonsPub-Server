# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Workers.ActivityWorkerTest do
  use MoodleNet.DataCase, async: true
  use Oban.Testing, repo: MoodleNet.Repo

  import MoodleNet.Test.Faking

  alias MoodleNet.{Common, Repo}

  describe "follow" do
    test "a user" do
      user = fake_user!()
      user2 = fake_user!()

      assert {:ok, follow} = Common.follow(user, user2, %{is_local: true})
      assert %{success: 1} = Oban.drain_queue(:mn_activities)

      assert [activity] = MoodleNet.Activities.list_by_context(follow)

      assert [user_inbox] = Repo.all(MoodleNet.Users.Inbox)
      assert user_inbox.user_id == user.id

      # FIXME: duplicate outbox
      assert [user_outbox, _] = Repo.all(MoodleNet.Users.Outbox)
      assert user_outbox.user_id == user.id
    end

    test "a community" do
      user = fake_user!()
      comm = fake_user!() |> fake_community!()

      assert {:ok, follow} = Common.follow(user, comm, %{is_local: true})
      assert %{success: 1} = Oban.drain_queue(:mn_activities)

      assert [activity] = MoodleNet.Activities.list_by_context(follow)

      assert [user_inbox] = Repo.all(MoodleNet.Users.Inbox)
      assert user_inbox.user_id == user.id

      assert [user_outbox] = Repo.all(MoodleNet.Users.Outbox)
      assert user_outbox.user_id == user.id

      assert [comm_outbox] = Repo.all(MoodleNet.Communities.Outbox)
      assert comm_outbox.community_id == comm.id
    end

    test "a collection" do
      user = fake_user!()

      creator = fake_user!()
      comm = fake_community!(creator)
      coll = fake_collection!(creator, comm)

      assert {:ok, follow} = Common.follow(user, coll, %{is_local: true})
      assert %{success: 1} = Oban.drain_queue(:mn_activities)

      assert [activity] = MoodleNet.Activities.list_by_context(follow)

      assert [user_inbox] = Repo.all(MoodleNet.Users.Inbox)
      assert user_inbox.user_id == user.id

      assert [user_outbox] = Repo.all(MoodleNet.Users.Outbox)
      assert user_outbox.user_id == user.id

      assert [comm_outbox] = Repo.all(MoodleNet.Communities.Outbox)
      assert comm_outbox.community_id == comm.id

      assert [coll_outbox] = Repo.all(MoodleNet.Collections.Outbox)
      assert coll_outbox.collection_id == coll.id
    end

    test "a thread" do
      user = fake_user!()

      creator = fake_user!()
      comm = fake_community!(creator)
      thread = fake_thread!(creator, comm)

      assert {:ok, follow} = Common.follow(user, thread, %{is_local: true})
      # one success is during the thread creation
      assert %{success: 2} = Oban.drain_queue(:mn_activities)

      assert [activity] = MoodleNet.Activities.list_by_context(follow)

      assert user_inboxes = Repo.all(MoodleNet.Users.Inbox)
      assert Enum.any?(user_inboxes, fn box -> box.user_id == user.id end)

      assert user_outboxes = Repo.all(MoodleNet.Users.Outbox)
      assert Enum.any?(user_outboxes, fn box -> box.user_id == user.id end)

      assert [comm_outbox] = Repo.all(MoodleNet.Communities.Outbox)
      assert comm_outbox.community_id == comm.id
    end

    test "a comment" do
      user = fake_user!()

      creator = fake_user!()
      comm = fake_community!(creator)
      thread = fake_thread!(creator, comm)
      comment = fake_comment!(creator, thread)

      assert {:ok, follow} = Common.follow(user, comment, %{is_local: true})
      # 2 successes from thread and comment
      assert %{success: 3} = Oban.drain_queue(:mn_activities)

      assert [activity] = MoodleNet.Activities.list_by_context(follow)

      assert [user_inbox] = Repo.all(MoodleNet.Users.Inbox)
      assert user_inbox.user_id == user.id

      # FIXME: duplicates
      assert user_outboxes = Repo.all(MoodleNet.Users.Outbox)
      assert Enum.any?(user_outboxes, fn box -> box.user_id == user.id end)

      assert [comm_outbox] = Repo.all(MoodleNet.Communities.Outbox)
      assert comm_outbox.community_id == comm.id
    end
  end
end
