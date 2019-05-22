defmodule MoodleNet.AP.SQLCollectionAspect do
  @moduledoc """
  SQLAspect for MoodleNet Collection Aspect
  """
  use ActivityPub.SQLAspect,
    aspect: MoodleNet.AP.CollectionAspect,
    persistence_method: :fields
end
