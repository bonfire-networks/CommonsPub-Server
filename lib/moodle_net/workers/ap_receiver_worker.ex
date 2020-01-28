defmodule MoodleNet.Workers.APReceiverWorker do
  use ActivityPub.Workers.WorkerHelper, queue: "ap_incoming"
  import MoodleNet.Workers.Utils, only: [configure_logger: 1]

  @impl Oban.Worker
  def perform(%{"op" => "handle_activity", "activity_id" => activity_id}, _job) do
    # configure_logger(__MODULE__)
    # activity = ActivityPub.Object.get_by_id(activity_id)
    # MoodleNet.ActivityPub.Adapter.perform(:handle_activity, activity)
    :ok
  end
end
