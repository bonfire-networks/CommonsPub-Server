# SPDX-License-Identifier: AGPL-3.0-only
defmodule CommonsPub.CharactersTest do
  use MoodleNet.DataCase, async: true

  import MoodleNet.Test.Faking
  alias MoodleNet.Repo

  alias CommonsPub.Character.Characters

  alias MoodleNet.Common.NotFoundError
  alias CommonsPub.Utils.Simulation

  def assert_actor_equal(actor, attrs) do
    assert actor.canonical_url == attrs[:canonical_url]
    assert actor.preferred_username == attrs[:preferred_username]
    assert actor.signing_key == attrs[:signing_key]
  end

  describe "one" do
    test "returns an item by ID" do
      actor = fake_user!().actor
      assert {:ok, fetched} = Characters.one(id: actor.id)
      assert actor == fetched
    end

    test "returns an item by username" do
      actor = fake_user!().actor
      assert {:ok, fetched} = Characters.one(username: actor.preferred_username)
      assert actor == fetched
    end

    test "fails if item is missing" do
      assert {:error, %NotFoundError{}} = Characters.one(id: Simulation.ulid())
    end
  end

  describe "is_username_available?" do
    test "returns true if username is unused" do
      assert Characters.is_username_available?(Simulation.preferred_username())
    end

    test "returns false if username is used" do
      actor = fake_user!().actor
      refute Characters.is_username_available?(actor.preferred_username)
    end
  end

  describe "create" do
    test "creates a new actor with a revision" do
      Repo.transaction(fn ->
        attrs = Simulation.actor()
        assert {:ok, actor} = Characters.create(attrs)
        assert_actor_equal(actor, attrs)
      end)
    end

    # test "drops invalid characters from preferred_username" do
    #  Repo.transaction(fn ->
    #    attrs = Simulation.actor(%{preferred_username: "actor&name"})
    #    assert {:ok, actor} = Characters.create(attrs)
    #    assert actor.preferred_username == "actorname"
    #  end)
    # end

    test "doesn't drop allowed characters from preferred_username" do
      Repo.transaction(fn ->
        attrs = Simulation.actor(%{preferred_username: "actor-name_underscore@instance.url"})
        assert {:ok, actor} = Characters.create(attrs)
        assert actor.preferred_username == "actor-name_underscore@instance.url"
      end)
    end

    test "returns an error if there are missing required attributes" do
      Repo.transaction(fn ->
        invalid_attrs = Map.delete(Simulation.actor(), :preferred_username)
        assert {:error, changeset} = Characters.create(invalid_attrs)
        assert Keyword.get(changeset.errors, :preferred_username)
      end)
    end

    test "returns an error if the username is duplicated" do
      Repo.transaction(fn ->
        user = fake_user!()

        actor = fake_actor!(user)

        assert {:error, changeset} =
                 %{preferred_username: actor.preferred_username}
                 |> Simulation.actor()
                 |> Characters.create()

        assert Keyword.get(changeset.errors, :preferred_username)
      end)
    end
  end

  describe "update" do
    test "updates an existing actor with valid attributes" do
      Repo.transaction(fn ->
        user = fake_user!()
        original_attrs = Simulation.actor()
        assert {:ok, actor} = Characters.create(original_attrs)

        updated_attrs =
          original_attrs
          |> Map.take(~w(preferred_username signing_key)a)
          |> Simulation.actor()

        assert {:ok, actor} = Characters.update(user, actor, updated_attrs)
        assert_actor_equal(actor, updated_attrs)
      end)
    end
  end
end
