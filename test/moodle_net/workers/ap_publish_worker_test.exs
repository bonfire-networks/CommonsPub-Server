defmodule Moodlenet.Workers.APPpublishWorkerTest do
  use MoodleNet.DataCase

  import ActivityPub.Factory
  import MoodleNet.Test.Faking
  alias MoodleNet.Workers.APPublishWorker

  describe "false locality checks" do
    test "it doesn't federate remote resource" do
      actor = actor()
      collection = collection()

      object = %{
        "name" => "resource",
        "url" => "http://www.guidetojapanese.org/grammar_guide.pdf",
        "actor" => actor.ap_id,
        "attributedTo" => actor.ap_id,
        "context" => collection.ap_id,
        "type" => "Document",
        "tag" => "GPL-v3",
        "summary" => "this is a resource",
        "icon" => "https://icon.store/picture.png"
      }

      params = %{
        actor: actor,
        to: ["https://www.w3.org/ns/activitystreams#Public"],
        object: object,
        context: collection.ap_id,
        additional: %{
          "cc" => [collection.data["followers"], actor.data["followers"]]
        },
        local: false
      }

      {:ok, activity} = ActivityPub.create(params)
      assert %{success: 1, failure: 0} = Oban.drain_queue(:ap_incoming)

      assert {:ok, resource} =
               MoodleNet.Repo.fetch_by(MoodleNet.Resources.Resource, %{
                 canonical_url: activity.object.data["id"]
               })

      assert :ignored = APPublishWorker.perform(%{"context_id" => resource.id}, %{})
    end

    test "it doesn't federate remote communities" do
      community = community()
      {:ok, community} = MoodleNet.Communities.one([:default, username: community.username])

      assert :ignored = APPublishWorker.perform(%{"context_id" => community.id}, %{})
    end

    test "it doesn't federate remote follows" do
      follower = actor()
      followed = fake_user!() |> fake_community!()
      {:ok, ap_followed} = ActivityPub.Actor.get_by_local_id(followed.id)
      {:ok, _} = ActivityPub.follow(follower, ap_followed, nil, false)
      assert %{success: 1, failure: 0} = Oban.drain_queue(:ap_incoming)
      {:ok, follower} = MoodleNet.ActivityPub.Adapter.get_actor_by_ap_id(follower.ap_id)
      {:ok, follow} = MoodleNet.Follows.one(creator_id: follower.id, context_id: followed.id)

      assert :ignored = APPublishWorker.perform(%{"context_id" => follow.id}, %{})
    end
  end

  describe "true locality checks" do
    test "it does federate local resources" do
      user = fake_user!()
      community = fake_community!(user)
      collection = fake_collection!(user, community)
      resource = fake_resource!(user, collection)

      assert {:ok, _} = APPublishWorker.perform(%{"context_id" => resource.id}, %{})
    end

    test "it does federate local communities" do
      community = fake_user!() |> fake_community!()

      assert {:ok, _} = APPublishWorker.perform(%{"context_id" => community.id}, %{})
    end

    test "it does federate local follows" do
      user = fake_user!()
      community = fake_user!() |> fake_community!()

      {:ok, follow} = MoodleNet.Follows.create(user, community, %{is_local: true})
      assert {:ok, _} = APPublishWorker.perform(%{"context_id" => follow.id}, %{})
    end

  end
end
