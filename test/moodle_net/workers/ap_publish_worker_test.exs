defmodule Moodlenet.Workers.APPpublishWorkerTest do
  use MoodleNet.DataCase

  import ActivityPub.Factory
  import MoodleNet.Test.Faking
  alias MoodleNet.Workers.APPublishWorker

  test "it doesn't federate remote resource" do
    actor = actor()
      collection = collection()

      object = %{
        "name" => "resource",
        "url" => "https://resource.com",
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
end
