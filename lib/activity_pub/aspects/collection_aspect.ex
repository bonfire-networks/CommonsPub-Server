defmodule ActivityPub.CollectionAspect do
  use ActivityPub.Aspect, persistence: ActivityPub.SQLCollectionAspect

  aspect do
    field(:total_items, :integer)
    # FIXME make just single
    assoc(:current)
    assoc(:first)
    assoc(:last)
    assoc(:items)

    field(:__ordered__, :boolean)
  end
end
