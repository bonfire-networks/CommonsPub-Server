# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.BlocksTest do
  use MoodleNet.DataCase, async: true
  use Oban.Testing, repo: MoodleNet.Repo
  require Ecto.Query
  import MoodleNet.Test.Faking
  alias MoodleNet.Blocks
  alias MoodleNet.Test.Fake

  setup do
    {:ok, %{user: fake_user!()}}
  end

  def fake_meta!() do
    user = fake_user!()
    community = fake_community!(user)
    collection = fake_collection!(user, community)
    # resource = fake_resource!(user, collection)
    thread = fake_thread!(user, collection)
    comment = fake_comment!(user, thread)
    Faker.Util.pick([user, community, collection, thread, comment])
  end

  describe "block/3" do
    test "creates a block for any meta object", %{user: blocker} do
      blocked = fake_meta!()

      assert {:ok, block} =
        Blocks.create(blocker, blocked, Fake.block(%{is_muted: true, is_blocked: true}))

      assert block.blocked_at
      # assert block.muted_at
    end
  end

  describe "update_block/2" do
    test "updates the attributes of an existing block", %{user: blocker} do
      blocked = fake_meta!()
      assert {:ok, block} = Blocks.create(blocker, blocked, Fake.block(%{is_blocked: false}))
      assert {:ok, updated_block} = Blocks.update(blocker, block, Fake.block(%{is_blocked: true}))
      assert block != updated_block
    end
  end

  describe "soft_delete/1" do
    test "removes a block", %{user: blocker} do
      blocked = fake_meta!()
      assert {:ok, block} = Blocks.create(blocker, blocked, Fake.block(%{is_blocked: false}))
      refute block.deleted_at

      assert {:ok, block} = Blocks.soft_delete(blocker, block)
      assert block.deleted_at
    end
  end

end
