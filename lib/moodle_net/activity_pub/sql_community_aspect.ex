defmodule MoodleNet.AP.SQLCommunityAspect do
  @moduledoc """
  MoodleNet Community ActivityPub Aspect
  """
  use ActivityPub.SQLAspect,
    aspect: MoodleNet.AP.CommunityAspect,
    persistence_method: :fields
end
