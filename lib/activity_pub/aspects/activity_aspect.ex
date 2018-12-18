defmodule ActivityPub.ActivityAspect do
  use ActivityPub.Aspect, persistence: ActivityPub.SQLActivityAspect

  aspect do
    assoc(:actor)
    assoc(:object)
    assoc(:target)
  end
end
