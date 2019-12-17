# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.LikesTest do
  use MoodleNet.DataCase, async: true
  use Oban.Testing, repo: MoodleNet.Repo
  require Ecto.Query
  import MoodleNet.Test.Faking
  alias MoodleNet.Likes
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

  describe "like/3" do
    test "a user can like any meta object", %{user: liker} do
      liked = fake_meta!()
      assert {:ok, like} = Likes.create(liker, liked, Fake.like())
      assert like.creator_id == liker.id
      assert like.context_id == liked.id
      assert like.published_at
    end
  end

  describe "likes_by/1" do
    test "returns a list of likes for an user", %{user: liker} do
      things = for _ <- 1..3, do: fake_meta!()

      for thing <- things do
        assert {:ok, like} = Likes.create(liker, thing, Fake.like())
      end

      likes = Likes.list_by(liker)
      assert Enum.count(likes) == 3

      for like <- likes do
        assert like.creator_id == liker.id
        assert Enum.any?(things, fn thing -> thing.id == like.context_id end)
      end
    end
  end

  describe "likes_of/1" do
    test "returns a list of likes by users for any meta object" do
      thing = fake_community!(fake_user!())
      users = for _ <- 1..3, do: fake_user!()

      for user <- users do
        assert {:ok, like} = Likes.create(user, thing, Fake.like())
      end

      likes = Likes.list_of(thing)
      assert Enum.count(likes) == 3

      for like <- likes do
        assert like.context_id == thing.id
        assert Enum.any?(users, fn user -> user.id == like.creator_id end)
      end
    end
  end

end
