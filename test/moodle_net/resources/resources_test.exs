# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNet.ResourcesTest do
  use MoodleNet.DataCase, async: true
  import MoodleNet.Test.Faking
  alias MoodleNet.{Resources, Repo}
  alias MoodleNet.Resources.ResourceRevision
  alias MoodleNet.Common.Revision
  alias MoodleNet.Test.Fake

  setup do
    actor = fake_actor!()
    language = fake_language!()
    community = fake_community!(actor, language)
    collection = fake_collection!(actor, community, language)
    resource = fake_resource!(actor, collection, language)
    {:ok, %{actor: actor, collection: collection, language: language, resource: resource}}
  end

  describe "fetch" do
    test "fetches an existing resource", %{resource: resource} do
      assert {:ok, _} = Resources.fetch(resource.id)
    end

    test "returns not found if the resource is missing" do
      assert {:error, %MoodleNet.Common.NotFoundError{}} = Resources.fetch(Faker.UUID.v4())
    end
  end

  describe "create" do
    test "creates a new resource given valid attributes", context do
      Repo.transaction(fn ->
        attrs = Fake.resource()

        assert {:ok, resource} =
                 Resources.create(
                   context.collection,
                   context.actor,
                   context.language,
                   attrs
                 )

        assert resource.current.content == attrs[:content]
        assert resource.current.url == attrs[:url]
      end)
    end

    test "creates a revision for the resource", %{resource: resource} do
      assert {:ok, resource} = Resources.fetch(resource.id)
      assert resource = Repo.preload(resource, [:revisions, :current])
      assert [revision] = resource.revisions
      assert revision == resource.current
    end

    test "fails given invalid attributes", context do
      Repo.transaction(fn ->
        assert {:error, changeset} =
                 Resources.create(
                   context.collection,
                   context.actor,
                   context.language,
                   %{}
                 )

        assert Keyword.get(changeset.errors, :is_public)
      end)
    end
  end

  describe "update" do
    test "updates a resource given valid attributes", context do
      resource =
        fake_resource!(
          context.actor,
          context.collection,
          context.language,
          %{is_public: true}
        )

      assert {:ok, updated_resource} = Resources.update(resource, %{is_public: false})
      assert updated_resource != resource
      refute updated_resource.is_public
    end

    test "creates a new revision for the update, keeping the old one", %{resource: resource} do
      assert {:ok, updated_resource} = Resources.update(resource, Fake.resource())
      assert updated_resource.current != resource.current

      assert updated_resource = Revision.preload(ResourceRevision, updated_resource)
      assert [latest_revision, oldest_revision] = updated_resource.revisions
      assert latest_revision != oldest_revision
      assert :gt = DateTime.compare(latest_revision.inserted_at, oldest_revision.inserted_at)
    end
  end
end
