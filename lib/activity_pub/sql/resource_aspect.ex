defmodule ActivityPub.SQLResourceAspect do
  use ActivityPub.SQLAspect,
    aspect: ActivityPub.ResourceAspect,
    persistence_method: :table,
    table_name: "activity_pub_resource_aspects"
end
