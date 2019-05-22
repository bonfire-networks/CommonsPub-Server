defmodule ActivityPub.ActivityAspect do
  @moduledoc """
  `ActivityAspect` implements _Activity_ as defined in the ActivityPub and ActivityStreams specifications.

  An `ActivityPub.Aspect` is a group of fields and functionality that an `ActivityPub.Entity` can have. `Aspects` are similar to [ActivityStreams core types](https://www.w3.org/TR/activitystreams-vocabulary/#types), but not exactly the same.

  The `ActivityPub.Aspect` is responsible for an `ActivityPub.Entity`'s fields and associations. An `ActivityPub.Entity` can implement one or more `Aspects` at the same time.

  A _Create_ _Activity_ for example, in addition of the `ActivityPub.ActivityAspect`, also has the `ActivityPub.ObjectAspect` which contains all the fields that any _Object_ can have: _id, type, attachment, audience, bcc, bto_, etc.
  """

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
