defmodule ActivityPub.Follow do
  use Ecto.Schema

  schema "activity_pub_follows" do
    belongs_to :follower_id, ActivityPub.Actor
    belongs_to :following_id, ActivityPub.Actor

    timestamps(updated_at: false)
  end
end
