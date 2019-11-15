# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.ResourcesTest do
  use MoodleNet.DataCase, async: true
  import MoodleNet.Test.Faking
  alias MoodleNet.{Resources, Repo}
  alias MoodleNet.Test.Fake

  setup do
    user = fake_user!()
    community = fake_community!(user)
    collection = fake_collection!(user, community)
    resource = fake_resource!(user, collection)
    {:ok, %{user: user, collection: collection, resource: resource}}
  end

  describe "fetch" do
    test "fetches an existing resource", %{resource: resource} do
      assert {:ok, _} = Resources.fetch(resource.id)
    end

    test "returns not found if the resource is missing" do
      assert {:error, %MoodleNet.Common.NotFoundError{}} = Resources.fetch(Fake.uuid())
    end
  end

  describe "create" do
    test "creates a new resource given valid attributes", context do
      Repo.transaction(fn ->
        attrs = Fake.resource()

        assert {:ok, resource} =
                 Resources.create(
                   context.collection,
                   context.user,
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
                   context.collection,
                   context.user,
                   %{}
                 )

        # assert Keyword.get(changeset.errors, :is_public)
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
