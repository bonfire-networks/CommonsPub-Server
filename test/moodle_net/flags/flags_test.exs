# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.CommonTest do
  use MoodleNet.DataCase, async: true
  use Oban.Testing, repo: MoodleNet.Repo
  require Ecto.Query
  import MoodleNet.Test.Faking
  alias MoodleNet.{Blocks, Common, Features, Flags, Follows, Likes}
  alias MoodleNet.Test.Fake

  setup do
    {:ok, %{user: fake_user!()}}
  end

  def fake_meta!() do
    user = fake_user!()
    community = fake_community!(user)
    collection = fake_collection!(user, community)
    resource = fake_resource!(user, collection)
    thread = fake_thread!(user, resource)
    comment = fake_comment!(user, thread)
    Faker.Util.pick([user, community, collection, resource, thread, comment])
  end

  describe "flag/3" do
    test "a user can flag any meta object", %{user: flagger} do
      flagged = fake_meta!()
      assert {:ok, flag} = Flags.create(flagger, flagged, Fake.flag())
      assert flag.creator_id == flagger.id
      assert flag.context_id == flagged.id
      assert flag.message
    end
  end

  describe "flag/4" do
    test "creates a flag referencing a community", %{user: flagger} do
      user = fake_user!()
      community = fake_community!(user)
      collection = fake_collection!(user, community)
      assert {:ok, flag} = Flags.create(flagger, collection, community, Fake.flag())
      assert flag.context_id == collection.id
      assert flag.community_id == community.id
    end
  end

  describe "flags_by/1" do
    test "returns a list of flags for an user", %{user: flagger} do
      things = for _ <- 1..3, do: fake_meta!()

      for thing <- things do
        assert {:ok, flag} = Flags.create(flagger, thing, Fake.flag())
      end

      flags = Flags.list_by(flagger)
      assert Enum.count(flags) == 3

      for flag <- flags do
        assert flag.creator_id == flagger.id
        assert Enum.any?(things, fn thing -> thing.id == flag.context_id end)
      end
    end
  end

  describe "flags_of/1" do
    test "returns a list of flags by users for any meta object", _ do
      thing = fake_meta!()
      users = for _ <- 1..3, do: fake_user!()

      for user <- users do
        assert {:ok, flag} = Flags.create(user, thing, Fake.flag())
      end

      flags = Flags.list_of(thing)
      assert Enum.count(flags) == 3

      for flag <- flags do
        assert flag.context_id == thing.id
        assert Enum.any?(users, fn user -> user.id == flag.creator_id end)
      end
    end
  end

  describe "flags_of_community/1" do
    test "returns a list of flags for a community", %{user: flagger} do
      things = for _ <- 1..3, do: fake_meta!()
      community = fake_community!(fake_user!())

      for thing <- things do
        assert {:ok, flag} = Flags.create(flagger, thing, community, Fake.flag())
      end

      flags = Flags.list_in_community(community)
      assert Enum.count(flags) == 3

      for flag <- flags do
        assert flag.community_id == community.id
      end
    end
  end

  describe "resolve_flag/1" do
    test "soft deletes a flag", %{user: flagger} do
      thing = fake_meta!()
      assert {:ok, flag} = Flags.create(flagger, thing, Fake.flag())
      refute flag.deleted_at

      assert {:ok, flag} = Flags.resolve(flag)
      assert flag.deleted_at
    end
  end

end
