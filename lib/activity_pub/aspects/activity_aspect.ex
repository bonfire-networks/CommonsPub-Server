defmodule ActivityPub.ActivityAspect do
  use ActivityPub.Aspect, persistence: ActivityPub.SQLActivityAspect

  aspect do
    field(:_public, :boolean, default: true)
    assoc(:actor)
    assoc(:object)
    assoc(:target)
    assoc(:origin)
    assoc(:result)
    assoc(:instrument)
    field(:_changes, :map, virtual: true)
  end
end
