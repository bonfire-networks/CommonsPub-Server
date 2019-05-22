defmodule MoodleNet.AP.SQLResourceAspect do
  @moduledoc """
  `ActivityPub.SQLAspect` for `ActivityPub.ResourceAspect`
  """
  use ActivityPub.SQLAspect,
    aspect: MoodleNet.AP.ResourceAspect,
    persistence_method: :table,
    table_name: "activity_pub_resource_aspects"
end
