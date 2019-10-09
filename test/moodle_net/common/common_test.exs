# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.CommonTest do
  use MoodleNet.DataCase, async: true
  require Ecto.Query
  import MoodleNet.Test.Faking
  alias MoodleNet.Actors.Actor
  alias MoodleNet.Common
  alias MoodleNet.Repo
  alias MoodleNet.Test.Fake

  setup do
    {:ok, %{actor: fake_actor!(), language: fake_language!()}}
  end

  def fake_meta!(language) do
    actor = fake_actor!()
    community = fake_community!(actor, language)
    collection = fake_collection!(actor, community, language)
    resource = fake_resource!(actor, collection, language)
    thread = fake_thread!(actor, resource)
    comment = fake_comment!(actor, thread)
    Faker.Util.pick([actor, community, collection, resource, comment])
  end

  describe "paginate" do
    test "can take a limit and an offset", %{actor: actor} do
      actors = [actor] ++ for _ <- 1..5, do: fake_actor!()

      actors =
        Enum.sort_by(actors, & &1.inserted_at, fn a, b -> :lt == DateTime.compare(a, b) end)

      query = Ecto.Query.from(_ in Actor)

      [first, second] =
        query
        |> Common.paginate(%{offset: 2, limit: 2})
        |> Repo.all()

      assert first.id == Enum.at(actors, 2).id
      assert second.id == Enum.at(actors, 3).id

      # no limit
      fetched =
        query
        |> Common.paginate(%{offset: 2})
        |> Repo.all()

      assert Enum.map(fetched, & &1.id) == actors |> Enum.drop(2) |> Enum.map(& &1.id)

      # no offset
      fetched =
        query
        |> Common.paginate(%{limit: 2})
        |> Repo.all()

      assert Enum.map(fetched, & &1.id) == actors |> Enum.take(2) |> Enum.map(& &1.id)

      # neither parameters
      fetched =
        query
        |> Common.paginate(%{})
        |> Repo.all()

      assert Enum.map(fetched, & &1.id) == actors |> Enum.map(& &1.id)
    end
  end

  describe "like/3" do
    test "an actor can like any meta object", %{actor: liker, language: language} do
      liked = fake_meta!(language)
      assert {:ok, like} = Common.like(liker, liked, %{is_public: true})
      assert like.liker_id == liker.id
      assert like.liked_id == liked.id
      assert like.published_at
    end
  end

  describe "likes_by/1" do
    test "returns a list of likes for an actor", %{actor: actor, language: language} do
      things = for _ <- 1..3, do: fake_meta!(language)

      for thing <- things do
        assert {:ok, like} = Common.like(actor, thing, %{is_public: true})
      end

      likes = Common.likes_by(actor)
      assert Enum.count(likes) == 3

      for like <- likes do
        assert like.liker_id == actor.id
        assert Enum.any?(things, fn thing -> thing.id == like.liked_id end)
      end
    end
  end

  describe "likes_of/1" do
    test "returns a list of likes by actors for any meta object", context do
      thing = fake_community!(context.actor, context.language)
      actors = for _ <- 1..3, do: fake_actor!()

      for actor <- actors do
        assert {:ok, like} = Common.like(actor, thing, %{is_public: true})
      end

      likes = Common.likes_of(thing)
      assert Enum.count(likes) == 3

      for like <- likes do
        assert like.liked_id == thing.id
        assert Enum.any?(actors, fn actor -> actor.id == like.liker_id end)
      end
    end
  end

  describe "flag/3" do
    test "an actor can flag any meta object", %{actor: flagger, language: language} do
      flagged = fake_meta!(language)
      assert {:ok, flag} = Common.flag(flagger, flagged, Fake.flag())
      assert flag.flagger_id == flagger.id
      assert flag.flagged_id == flagged.id
      assert flag.message
    end
  end

  describe "flag/4" do
    test "creates a flag referencing a community", %{actor: flagger, language: language} do
      actor = fake_actor!()
      community = fake_community!(actor, language)
      collection = fake_collection!(actor, community, language)
      assert {:ok, flag} = Common.flag(flagger, collection, community, Fake.flag())
      assert flag.flagged_id == collection.id
      assert flag.community_id == community.id
    end
  end

  describe "flags_by/1" do
    test "returns a list of flags for an actor", %{actor: flagger, language: language} do
      things = for _ <- 1..3, do: fake_meta!(language)

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
    test "returns a list of flags by actors for any meta object", %{language: language} do
      thing = fake_meta!(language)
      actors = for _ <- 1..3, do: fake_actor!()

      for actor <- actors do
        assert {:ok, flag} = Common.flag(actor, thing, Fake.flag())
      end

      flags = Common.flags_of(thing)
      assert Enum.count(flags) == 3

      for flag <- flags do
        assert flag.flagged_id == thing.id
        assert Enum.any?(actors, fn actor -> actor.id == flag.flagger_id end)
      end
    end
  end

  describe "flags_of_community/1" do
    test "returns a list of flags for a community", %{actor: flagger, language: language} do
      things = for _ <- 1..3, do: fake_meta!(language)
      community = fake_community!(fake_actor!(), language)

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
    test "soft deletes a flag", %{actor: flagger, language: language} do
      thing = fake_meta!(language)
      assert {:ok, flag} = Common.flag(flagger, thing, Fake.flag())
      refute flag.deleted_at

      assert {:ok, flag} = Common.resolve_flag(flag)
      assert flag.deleted_at
    end
  end

  describe "follow/3" do
    test "creates a follow for any meta object", %{actor: follower, language: language} do
      followed = fake_meta!(language)

      assert {:ok, follow} =
               Common.follow(follower, followed, %{is_public: true, is_muted: false})

      assert follow.follower_id == follower.id
      assert follow.followed_id == followed.id
      assert follow.published_at
      refute follow.muted_at
    end

    test "can mute a follow", %{actor: follower, language: language} do
      followed = fake_meta!(language)
      assert {:ok, follow} = Common.follow(follower, followed, %{is_public: true, is_muted: true})
      assert follow.muted_at
    end

    test "fails to create a follow with missing attributes", %{
      actor: follower,
      language: language
    } do
      followed = fake_meta!(language)
      assert {:error, _} = Common.follow(follower, followed, %{})
    end
  end

  describe "update_follow/2" do
    test "updates the attributes of an existing follow", %{actor: follower, language: language} do
      followed = fake_meta!(language)
      assert {:ok, follow} = Common.follow(follower, followed, Fake.follow(%{is_public: false}))
      assert {:ok, updated_follow} = Common.update_follow(follow, Fake.follow(%{is_public: true}))
      assert follow != updated_follow
    end
  end

  describe "unfollow/1" do
    test "removes a follower from a followed object", %{actor: follower, language: language} do
      followed = fake_meta!(language)
      assert {:ok, follow} = Common.follow(follower, followed, Fake.follow())
      refute follow.deleted_at

      assert {:ok, follow} = Common.unfollow(follow)
      assert follow.deleted_at
    end
  end
end
