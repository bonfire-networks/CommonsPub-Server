defmodule ActivityPub.SQLActorAspect do
  @moduledoc """
  `ActivityPub.SQLAspect` for `ActivityPub.ActorAspect`
  """

  use ActivityPub.SQLAspect,
    aspect: ActivityPub.ActorAspect,
    persistence_method: :table,
    table_name: "activity_pub_actor_aspects"
end
