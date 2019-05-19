defmodule ActivityPub.SQLObjectAspect do
  @moduledoc """
  `ActivityPub.SQLAspect` for `ActivityPub.ObjectAspect`
  """

  alias ActivityPub.ObjectAspect

  use ActivityPub.SQLAspect,
    aspect: ObjectAspect,
    persistence_method: :fields
end
