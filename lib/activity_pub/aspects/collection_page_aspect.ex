defmodule ActivityPub.CollectionPageAspect do
  use ActivityPub.Aspect, persistence: ActivityPub.SQLCollectionPageAspect

  aspect do
    # FIXME make just single
    assoc(:part_of)
    assoc(:next)
    assoc(:prev)
  end
end

