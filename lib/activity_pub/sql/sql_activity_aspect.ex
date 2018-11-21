defmodule ActivityPub.SQLActivityAspect do
  use Ecto.Schema

  # alias ActivityPub.SQLObject

  @primary_key {:local_id, :id, autogenerate: true}
  schema "activity_pub_activity_aspects" do
    # many_to_many :actor, SQLObject, join_through: "activity_pub_activity_actors",
    # join_keys: [local_id: :activity_id, object_id: :local_id]
  end
end
