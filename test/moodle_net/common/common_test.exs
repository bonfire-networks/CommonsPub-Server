# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.CommonTest do
  use MoodleNet.DataCase, async: true
  require Ecto.Query
  import MoodleNet.Test.Faking
  alias MoodleNet.Common
  alias MoodleNet.Repo
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
    Faker.Util.pick([user, community, collection, resource, comment])
  end

  # describe "paginate" do
  #   test "can take a limit and an offset", %{user: user} do
  #     users = [user] ++ for _ <- 1..4, do: fake_user!()

  #     users =
  #       Enum.sort_by(users, & &1.inserted_at, fn a, b -> :lt == DateTime.compare(a, b) end)

  #     query = Ecto.Query.from(_ in User)

  #     [first, second] =
  #       query
  #       |> Common.paginate(%{offset: 2, limit: 2})
  #       |> Repo.all()

  #     assert first.id == Enum.at(users, 2).id
  #     assert second.id == Enum.at(users, 3).id

  #     # no limit
  #     fetched =
  #       query
  #       |> Common.paginate(%{offset: 2})
  #       |> Repo.all()

  #     assert Enum.map(fetched, & &1.id) == users |> Enum.drop(2) |> Enum.map(& &1.id)

  #     # no offset
  #     fetched =
  #       query
  #       |> Common.paginate(%{limit: 2})
  #       |> Repo.all()

  #     assert Enum.map(fetched, & &1.id) == users |> Enum.take(2) |> Enum.map(& &1.id)

  #     # neither parameters
  #     fetched =
  #       query
  #       |> Common.paginate(%{})
  #       |> Repo.all()

  #     assert Enum.map(fetched, & &1.id) == users |> Enum.map(& &1.id)
  #   end
  # end

  describe "like/3" do
    test "a user can like any meta object", %{user: liker} do
      liked = fake_meta!()
      assert {:ok, like} = Common.like(liker, liked, Fake.like())
      assert like.liker_id == liker.id
      assert like.liked_id == liked.id
      assert like.published_at
    end
  end

  describe "likes_by/1" do
    test "returns a list of likes for an user", %{user: liker} do
      things = for _ <- 1..3, do: fake_meta!()

      for thing <- things do
        assert {:ok, like} = Common.like(liker, thing, Fake.like())
      end

      likes = Common.likes_by(liker)
      assert Enum.count(likes) == 3

      for like <- likes do
        assert like.liker_id == liker.id
        assert Enum.any?(things, fn thing -> thing.id == like.liked_id end)
      end
    end
  end

  describe "likes_of/1" do
    test "returns a list of likes by users for any meta object", context do
      thing = fake_community!(fake_user!())
      users = for _ <- 1..3, do: fake_user!()

      for user <- users do
        assert {:ok, like} = Common.like(user, thing, Fake.like())
      end

      likes = Common.likes_of(thing)
      assert Enum.count(likes) == 3

      for like <- likes do
        assert like.liked_id == thing.id
        assert Enum.any?(users, fn user -> user.id == like.liker_id end)
      end
    end
  end

  describe "flag/3" do
    test "a user can flag any meta object", %{user: flagger} do
      flagged = fake_meta!()
      assert {:ok, flag} = Common.flag(flagger, flagged, Fake.flag())
      assert flag.flagger_id == flagger.id
      assert flag.flagged_id == flagged.id
      assert flag.message
    end
  end

  describe "flag/4" do
    test "creates a flag referencing a community", %{user: flagger} do
      user = fake_user!()
      community = fake_community!(user)
      collection = fake_collection!(user, community)
      assert {:ok, flag} = Common.flag(flagger, collection, community, Fake.flag())
      assert flag.flagged_id == collection.id
      assert flag.community_id == community.id
    end
  end

  describe "flags_by/1" do
    test "returns a list of flags for an user", %{user: flagger} do
      things = for _ <- 1..3, do: fake_meta!()

      for thing <- things do
        assert {:ok, flag} = Common.flag(flagger, thing, Fake.flag())
      end

      flags = Common.flags_by(flagger)
      assert Enum.count(flags) == 3

      for flag <- flags do
        assert flag.flagger_id == flagger.id
        assert Enum.any?(things, fn thing -> thing.id == flag.flagged_id end)
      end
    end
  end

  describe "flags_of/1" do
    test "returns a list of flags by users for any meta object", _ do
      thing = fake_meta!()
      users = for _ <- 1..3, do: fake_user!()

      for user <- users do
        assert {:ok, flag} = Common.flag(user, thing, Fake.flag())
      end

      flags = Common.flags_of(thing)
      assert Enum.count(flags) == 3

      for flag <- flags do
        assert flag.flagged_id == thing.id
        assert Enum.any?(users, fn user -> user.id == flag.flagger_id end)
      end
    end
  end

  describe "flags_of_community/1" do
    test "returns a list of flags for a community", %{user: flagger} do
      things = for _ <- 1..3, do: fake_meta!()
      community = fake_community!(fake_user!())

      for thing <- things do
        assert {:ok, flag} = Common.flag(flagger, thing, community, Fake.flag())
      end

      flags = Common.flags_of_community(community)
      assert Enum.count(flags) == 3

      for flag <- flags do
        assert flag.community_id == community.id
      end
    end
  end

  describe "resolve_flag/1" do
    test "soft deletes a flag", %{user: flagger} do
      thing = fake_meta!()
      assert {:ok, flag} = Common.flag(flagger, thing, Fake.flag())
      refute flag.deleted_at

      assert {:ok, flag} = Common.resolve_flag(flag)
      assert flag.deleted_at
    end
  end

  describe "list_follows/1" do
    test "returns a list of follows for a user", %{user: follower} do
      follows = for _ <- 1..5 do
        followed = fake_meta!()
        assert {:ok, follow} = Common.follow(follower, followed, Fake.follow())
        follow
      end
      fetched = Common.list_follows(follower)

      assert Enum.count(fetched) == Enum.count(follows)
    end
  end

  describe "list_by_followed/1" do
    test "returns a list of follows for an item" do
      followed = fake_meta!()
      follows = for _ <- 1..5 do
        follower = fake_user!()
        assert {:ok, follow} = Common.follow(follower, followed, Fake.follow())
        follow
      end
      fetched = Common.list_by_followed(followed)

      assert Enum.count(fetched) == Enum.count(follows)

      for follow <- fetched do
        assert follow.followed
        assert follow.follower
      end
    end
  end

  describe "follow/3" do
    test "creates a follow for any meta object", %{user: follower} do
      followed = fake_meta!()

      attrs = Fake.follow(%{is_public: true, is_muted: false})
      assert {:ok, follow} = Common.follow(follower, followed, attrs)

      assert follow.follower_id == follower.id
      assert follow.followed_id == followed.id
      assert follow.published_at
      refute follow.muted_at
    end

    # test "can mute a follow", %{user: follower} do
    #   followed = fake_meta!()
    #   assert {:ok, follow} = Common.follow(follower, followed, Fake.follow(%{is_muted: true}))
    #   assert follow.muted_at
    # end

    test "fails to create a follow with missing attributes", %{user: follower} do
      followed = fake_meta!()
      assert {:error, _} = Common.follow(follower, followed, %{})
    end
  end

  describe "update_follow/2" do
    test "updates the attributes of an existing follow", %{user: follower} do
      followed = fake_meta!()
      assert {:ok, follow} = Common.follow(follower, followed, Fake.follow(%{is_public: false}))
      assert {:ok, updated_follow} = Common.update_follow(follow, Fake.follow(%{is_public: true}))
      assert follow != updated_follow
    end
  end

  describe "undo_follow/1" do
    test "removes a follower from a followed object", %{user: follower} do
      followed = fake_meta!()
      assert {:ok, follow} = Common.follow(follower, followed, Fake.follow())
      refute follow.deleted_at

      assert {:ok, follow} = Common.undo_follow(follow)
      assert follow.deleted_at
    end
  end

  describe "block/3" do
    test "creates a block for any meta object", %{user: blocker} do
      blocked = fake_meta!()

      assert {:ok, block} =
               Common.block(blocker, blocked, Fake.block(%{is_muted: true, is_blocked: true}))

      assert block.blocked_at
      # assert block.muted_at
    end
  end

  describe "update_block/2" do
    test "updates the attributes of an existing block", %{user: blocker} do
      blocked = fake_meta!()
      assert {:ok, block} = Common.block(blocker, blocked, Fake.block(%{is_blocked: false}))
      assert {:ok, updated_block} = Common.update_block(block, Fake.block(%{is_blocked: true}))
      assert block != updated_block
    end
  end

  describe "delete_block/1" do
    test "removes a block", %{user: blocker} do
      blocked = fake_meta!()
      assert {:ok, block} = Common.block(blocker, blocked, Fake.block(%{is_blocked: false}))
      refute block.deleted_at

      assert {:ok, block} = Common.delete_block(block)
      assert block.deleted_at
    end
  end

  # describe "tag/3" do
  #   test "creates a tag for any meta object", %{user: tagger} do
  #     tagged = fake_meta!()

  #     assert {:ok, tag} =
  #              Common.tag(tagger, tagged, Fake.tag(%{is_public: true, name: "Testing"}))

  #     assert tag.published_at
  #     assert tag.name == "Testing"
  #   end

  #   test "fails to create a tag if attributes are missing", %{user: tagger} do
  #     tagged = fake_meta!()
  #     assert {:error, changeset} = Common.tag(tagger, tagged, %{})
  #     assert Keyword.get(changeset.errors, :name)
  #   end
  # end

  # describe "update_tag/2" do
  #   test "updates the attributes of an existing tag", %{user: tagger} do
  #     tagged = fake_meta!()
  #     assert {:ok, tag} = Common.tag(tagger, tagged, Fake.tag(%{name: "Testy No.1"}))
  #     assert {:ok, updated_tag} = Common.update_tag(tag, %{name: "Testy Mc.Testface"})
  #     assert tag != updated_tag
  #   end

  #   test "fails to update if attributes are missing", %{user: tagger} do
  #     tagged = fake_meta!()
  #     assert {:error, changeset} = Common.tag(tagger, tagged, %{})
  #     assert Keyword.get(changeset.errors, :name)
  #   end
  # end

  # describe "untag/1" do
  #   test "removes a tag", %{user: tagger} do
  #     tagged = fake_meta!()
  #     assert {:ok, tag} = Common.tag(tagger, tagged, Fake.tag())
  #     refute tag.deleted_at
  #     assert {:ok, tag} = Common.untag(tag)
  #     assert tag.deleted_at
  #   end
  # end
end
