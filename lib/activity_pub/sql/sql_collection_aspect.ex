defmodule ActivityPub.SQLCollectionAspect do
  @moduledoc """
  `ActivityPub.SQLAspect` for `ActivityPub.CollectionAspect`
  """

  use ActivityPub.SQLAspect,
    aspect: ActivityPub.CollectionAspect,
    persistence_method: :table,
    table_name: "activity_pub_collection_aspects"
end
