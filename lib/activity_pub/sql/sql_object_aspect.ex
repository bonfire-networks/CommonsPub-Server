defmodule ActivityPub.SQLObjectAspect do
  alias ActivityPub.ObjectAspecto, as: ObjectAspect

  use ActivityPub.SQLAspect,
    aspect: ObjectAspect,
    persistence_method: :fields
end
