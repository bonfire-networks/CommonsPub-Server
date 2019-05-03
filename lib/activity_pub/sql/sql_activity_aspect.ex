defmodule ActivityPub.SQLActivityAspect do
  use ActivityPub.SQLAspect,
    aspect: ActivityPub.ActivityAspect,
    persistence_method: :table,
    table_name: "activity_pub_activity_aspects"
end
