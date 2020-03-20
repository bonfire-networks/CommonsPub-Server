defmodule MoodleNet.FeedPublisher do
  @moduledoc """
  A background process responsible for bulk publishing items to feeds
  """

  alias MoodleNet.Repo

  def publish(%{"context_id" => _} = args) do
    Ecto.Multi.new()
    |> Oban.insert(:ap_publish_job, MoodleNet.Workers.APPublishWorker.new(args))
    |> Repo.transaction()
    |> case do
         {:ok,_} -> :ok
         other -> other
       end
  end

end
