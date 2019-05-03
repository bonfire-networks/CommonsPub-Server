defmodule ActivityPub.SQLObjectAspect do
  alias ActivityPub.ObjectAspect

  use ActivityPub.SQLAspect,
    aspect: ObjectAspect,
    persistence_method: :fields
end
