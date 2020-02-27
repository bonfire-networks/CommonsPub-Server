# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.ResourcesTest do
  use MoodleNet.DataCase, async: true
  import MoodleNet.Test.Faking
  alias MoodleNet.{Collections, Resources, Repo}
  alias MoodleNet.Users.User
  alias MoodleNet.Test.Fake

  setup do
    user = fake_user!()
    community = fake_community!(user)
    collection = fake_collection!(user, community)
    resource = fake_resource!(user, collection)
    {:ok, %{user: user, collection: collection, resource: resource}}
  end

  describe "many" do
    test "fetches a list of non-deleted, public resources", context do
      all = for _ <- 1..4 do
        user = fake_user!()
        community = fake_community!(user)
        collection = fake_collection!(user, community)
        fake_resource!(user, collection)
      end ++ [context.resource]
      deleted = Enum.reduce(all, [], fn resource, acc ->
        if Fake.bool() do
          {:ok, resource} = Resources.soft_delete(resource)
          [resource | acc]
        else
          acc
        end
      end)
      {:ok, fetched} = Resources.many(:deleted)

      assert Enum.count(all) - Enum.count(deleted) == Enum.count(fetched)
    end

    test "ignores resources that have a deleted community", context do
      assert {:ok, collection} = Collections.soft_delete(context.collection)

      # one of the resources is in context
      for _ <- 1..4 do
        user = fake_user!()
        fake_resource!(user, collection)
      end

      {:ok, fetched} = Resources.many(:deleted)
      assert Enum.empty?(fetched)
    end

    test "returns a list of non-deletd resources in a collection", context do
      resources = for _ <- 1..4 do
        user = fake_user!()
        fake_resource!(user, context.collection)
      end ++ [context.resource]

      # outside of collection
      user = fake_user!()
      comm = fake_community!(user)
      fake_resource!(user, fake_collection!(user, comm))

      {:ok, fetched} = Resources.many(collection_id: context.collection.id)
      assert Enum.count(resources) == Enum.count(fetched)
    end
  end

  describe "one" do
    test "fetches an existing resource", %{resource: resource} do
      assert {:ok, resource} = Resources.one(id: resource.id)
      assert resource.creator
    end

    test "returns not found if the resource is missing" do
      assert {:error, %MoodleNet.Common.NotFoundError{}} = Resources.one(id: Fake.ulid())
    end
  end

  # deprecated function?
  @tag :skip
  describe "fetch_creator" do
    test "fetches the creator of a resource", context do
      assert {:ok, %User{} = user} = Resources.fetch_creator(context.resource)
      assert user.id == context.user.id
    end
  end

  describe "create" do
    test "creates a new resource given valid attributes", context do
      Repo.transaction(fn ->
        attrs = Fake.resource()

        assert {:ok, resource} =
                 Resources.create(
                   context.user,
                   context.collection,
                   attrs
                 )

        assert resource.name == attrs[:name]
        assert resource.url == attrs[:url]
      end)
    end

    test "fails given invalid attributes", context do
      Repo.transaction(fn ->
        assert {:error, changeset} =
                 Resources.create(
                   context.user,
                   context.collection,
                   %{}
                 )

        assert Keyword.get(changeset.errors, :name)
      end)
    end
  end

  describe "update" do
    test "updates a resource given valid attributes", context do
      attrs = Fake.resource()
      resource = fake_resource!(context.user, context.collection)

      assert {:ok, updated_resource} = Resources.update(resource, attrs)
      assert updated_resource != resource
      assert updated_resource.name == attrs[:name]
      assert updated_resource.url == attrs[:url]
    end
  end
end
