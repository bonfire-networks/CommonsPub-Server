defmodule MoodleNet.ActivityPub.Adapter do
  alias MoodleNet.Actors

  @behaviour ActivityPub.Adapter

  def get_actor_by_username(username) do
    Actors.fetch_by_username(username)
  end

  def handle_activity(_activity) do
    :ok
  end
end
