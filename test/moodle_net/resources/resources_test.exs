# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.ResourcesTest do
  use MoodleNet.DataCase
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

  describe "one" do
    test "fetches an existing resource", %{resource: resource} do
      assert {:ok, resource} = Resources.one(id: resource.id)
      assert resource.creator
    end

    test "returns not found if the resource is missing" do
      assert {:error, %MoodleNet.Common.NotFoundError{}} = Resources.one(id: Fake.ulid())
    end
  end

  describe "create" do
    test "creates a new resource given valid attributes", context do
      Repo.transaction(fn ->
        content = fake_content!(context.user)
        attrs = Fake.resource() |> Map.put(:content_id, content.id)

        assert {:ok, resource} =
                 Resources.create(
                   context.user,
                   context.collection,
                   attrs
                 )

        assert resource.name == attrs[:name]
        assert resource.content_id == content.id
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
    end
  end
end
