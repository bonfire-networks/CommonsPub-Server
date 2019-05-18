defmodule ActivityPub.LinkAspect do
  @moduledoc """
`LinkAspect` implements _Link_ as defined in the ActivityPub and ActivityStreams specifications.

An `ActivityPub.Aspect` is a group of fields and functionality that an `ActivityPub.Entity` can have. `Aspects` are similar to [ActivityStreams core types](https://www.w3.org/TR/activitystreams-vocabulary/#types), but not exactly the same.

The `ActivityPub.Aspect` is responsible for an `ActivityPub.Entity`'s fields and associations. An `ActivityPub.Entity` can implement one or more `Aspects` at the same time.
  """
  use ActivityPub.Aspect, persistence: ActivityPub.SQLLinkAspect

  aspect do
    field(:href, :string)
    field(:rel, :string)
    field(:media_type, :string)
    field(:name, :string)
    field(:hreflang, :string)
    field(:height, :string)
    field(:width, :string)
    field(:preview, :string)
  end
end
