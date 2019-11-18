defmodule MoodleNet.Workers.APReceiverWorker do
  use ActivityPub.Workers.WorkerHelper, queue: "ap_icoming"

  @impl Oban.Worker
  def perform(%{"op" => "handle_activity", "activity_id" => activity_id}, _job) do
    activity = ActivityPub.Object.get_by_id(activity_id)
    MoodleNet.ActivityPub.Adapter.perform(:handle_activity, activity)
  end
end
