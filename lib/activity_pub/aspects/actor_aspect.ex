defmodule ActivityPub.ActorAspect do
  use ActivityPub.Aspect, persistence: ActivityPub.SQLActorAspect

  aspect do
    field(:inbox, :string)
    field(:outbox, :string)
    field(:following, :string)
    field(:followers, :string)
    field(:liked, :string)
    field(:preferred_username, :string)
    field(:streams, {:map, :string})
    field(:endpoints, {:map, :string})

    field(:followers_count, :integer, default: 0)
    field(:following_count, :integer, default: 0)
  end
end
