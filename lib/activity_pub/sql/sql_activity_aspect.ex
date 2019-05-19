defmodule ActivityPub.SQLActivityAspect do
  @moduledoc """
  `ActivityPub.SQLAspect` for `ActivityPub.ActivityAspect`
  """

  use ActivityPub.SQLAspect,
    aspect: ActivityPub.ActivityAspect,
    persistence_method: :table,
    table_name: "activity_pub_activity_aspects"
end
