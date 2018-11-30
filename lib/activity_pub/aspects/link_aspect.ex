defmodule ActivityPub.LinkAspect do
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
