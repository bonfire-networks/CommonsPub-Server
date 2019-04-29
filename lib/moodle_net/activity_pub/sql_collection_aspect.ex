defmodule MoodleNet.AP.SQLCollectionAspect do
  use ActivityPub.SQLAspect,
    aspect: MoodleNet.AP.CollectionAspect,
    persistence_method: :fields
end
