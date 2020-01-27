# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.FeaturesTest do
  use MoodleNet.DataCase, async: true
  use Oban.Testing, repo: MoodleNet.Repo
  require Ecto.Query
  import MoodleNet.Test.Faking
  alias MoodleNet.Collections.Collection
  alias MoodleNet.Communities.Community
  alias MoodleNet.Features
  alias MoodleNet.Meta.Pointers

  def fake_featurable!() do
    user = fake_user!()
    community = fake_community!(user)
    collection = fake_collection!(user, community)
    Faker.Util.pick([community, collection])
  end

  describe "fetch/1" do
    test "works" do
      alice = fake_user!()
      comm = fake_community!(alice)
      assert {:ok, feat} = Features.create(alice, comm, %{is_local: true})
      assert feat.context_id == comm.id
      assert {:ok, feat2} = Features.fetch(feat.id)
      assert Map.delete(feat, :context) == Map.delete(feat2, :context)
    end
  end

  describe "list/1" do
    test "returns an empty list when there are no features" do
      assert [] == Features.list()
    end

    test "returns a list of featured communities and collections" do
      alice = fake_user!()
      c1 = fake_community!(alice)
      c2 = fake_collection!(alice, c1)
      c3 = fake_community!(alice)
      c4 = fake_collection!(alice, c3)
      c5 = fake_community!(alice)
      _c6 = fake_collection!(alice, c5)
      assert {:ok, f1} = Features.create(alice, c1, %{is_local: true})
      assert {:ok, f2} = Features.create(alice, c2, %{is_local: true})
      assert {:ok, f3} = Features.create(alice, c3, %{is_local: true})
      assert {:ok, f4} = Features.create(alice, c4, %{is_local: true})
      check = [{f4, c4}, {f3, c3}, {f2, c2}, {f1, c1}]
      assert features = Features.list()
      assert Enum.count(features) == 4
      for {pulled, {f, c}} <- Enum.zip(features, check) do
        assert Map.delete(pulled, :context) == Map.delete(f, :context)
        c2 = Map.drop(c, [:actor, :is_disabled, :is_public])
        ctx = Map.drop(Pointers.follow!(pulled.context), [:actor, :is_disabled, :is_public])
        assert ctx == c2
      end
    end

    test "returns a list of featured communities" do
      alice = fake_user!()
      c1 = fake_community!(alice)
      c2 = fake_community!(alice)
      c3 = fake_community!(alice)
      _c4 = fake_community!(alice)
      _c5 = fake_collection!(alice, c1)
      assert {:ok, f1} = Features.create(alice, c1, %{is_local: true})
      assert {:ok, f2} = Features.create(alice, c2, %{is_local: true})
      assert {:ok, f3} = Features.create(alice, c3, %{is_local: true})
      check = [{f3, c3}, {f2, c2}, {f1, c1}]
      assert features = Features.list(%{contexts: [Community]})
      assert Enum.count(features) == 3
      for {pulled, {f, c}} <- Enum.zip(features, check) do
        assert Map.delete(pulled, :context) == Map.delete(f, :context)
        c2 = Map.drop(c, [:actor, :is_disabled, :is_public])
        ctx = Map.drop(Pointers.follow!(pulled.context), [:actor, :is_disabled, :is_public])
        assert ctx == c2
      end
    end

    test "returns a list of featured collections" do
      alice = fake_user!()
      comm = fake_community!(alice)
      c1 = fake_collection!(alice, comm)
      c2 = fake_collection!(alice, comm)
      c3 = fake_collection!(alice, comm)
      _c4 = fake_collection!(alice, comm)
      _c5 = fake_community!(alice)
      assert {:ok, f1} = Features.create(alice, c1, %{is_local: true})
      assert {:ok, f2} = Features.create(alice, c2, %{is_local: true})
      assert {:ok, f3} = Features.create(alice, c3, %{is_local: true})
      check = [{f3, c3}, {f2, c2}, {f1, c1}]
      assert features = Features.list(%{contexts: [Collection]})
      assert Enum.count(features) == 3
      for {pulled, {f, c}} <- Enum.zip(features, check) do
        assert Map.delete(pulled, :context) == Map.delete(f, :context)
        c2 = Map.drop(c, [:actor, :is_disabled, :is_public])
        ctx = Map.drop(Pointers.follow!(pulled.context), [:actor, :is_disabled, :is_public])
        assert ctx == c2
      end
    end
  end

  describe "create/3" do
    test "creates a feature for a collection" do
      alice = fake_user!()
      comm = fake_community!(alice)
      coll = fake_collection!(alice, comm)
      assert {:ok, feat} = Features.create(alice, coll, %{is_local: true})
      assert feat.context_id == coll.id
    end
    test "creates a feature for a community" do
      alice = fake_user!()
      comm = fake_community!(alice)
      assert {:ok, feat} = Features.create(alice, comm, %{is_local: true})
      assert feat.context_id == comm.id
    end

  end

  describe "delete/1" do
    test "removes a feature" do
      alice = fake_user!()
      comm = fake_community!(alice)
      assert {:ok, feat} = Features.create(alice, comm, %{is_local: true})
      assert feat.context_id == comm.id
      assert {:ok, feat2} = Features.fetch(feat.id)
      assert Map.delete(feat, :context) == Map.delete(feat2, :context)
      assert {:ok, _} = Features.delete(feat)
      assert {:error, _} = Features.fetch(feat.id)
    end
  end

end
