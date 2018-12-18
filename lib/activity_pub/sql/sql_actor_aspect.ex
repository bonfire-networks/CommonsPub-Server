defmodule ActivityPub.SQLActorAspect do
  use ActivityPub.SQLAspect,
    aspect: ActivityPub.ActorAspect,
    persistence_method: :table,
    table_name: "activity_pub_actor_aspects"
end
