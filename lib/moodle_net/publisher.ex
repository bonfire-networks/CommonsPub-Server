defmodule MoodleNet.FeedPublisher do
  @moduledoc """
  A background process responsible for bulk publishing items to feeds
  """

  use GenServer

  def init(_) do
    {:ok, []}
  end

end
