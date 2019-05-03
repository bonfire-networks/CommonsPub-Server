defmodule MoodleNet.AP.SQLCommunityAspect do
  use ActivityPub.SQLAspect,
    aspect: MoodleNet.AP.CommunityAspect,
    persistence_method: :fields
end
