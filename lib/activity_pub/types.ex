defmodule ActivityPub.Types do
  alias ActivityPub.{
    ObjectAspect,
    ActorAspect,
    ActivityAspect,
    LinkAspect,
    CollectionAspect,
    CollectionPageAspect
  }

  @type_map %{
    "Link" => {[], [LinkAspect]},
    "Object" => {[], [ObjectAspect]},
    "Collection" => {~w[Object], [CollectionAspect]},
    "OrderedCollection" => {~w[Object Collection], []},
    "CollectionPage" => {~w[Object Collection], [CollectionPageAspect]},
    "OrderedCollectionPage" => {~w[Object Collection OrderedCollection CollectionPage], []},
    "Actor" => {~w[Object], [ActorAspect]},
    "Application" => {~w[Object Actor], []},
    "Group" => {~w[Object Actor], []},
    "Organization" => {~w[Object Actor], []},
    "Person" => {~w[Object Actor], []},
    "Service" => {~w[Object Actor], []},
    "Activity" => {~w[Object], [ActivityAspect]},
    "IntransitiveActivity" => {~w[Object Activity], []},
    "Accept" => {~w[Object Activity], []},
    "Add" => {~w[Object Activity], []},
    "Announce" => {~w[Object Activity], []},
    "Arrive" => {~w[Object Activity], []},
    "Block" => {~w[Object Activity], []},
    "Create" => {~w[Object Activity], []},
    "Delete" => {~w[Object Activity], []},
    "Dislike" => {~w[Object Activity], []},
    "Flag" => {~w[Object Activity], []},
    "Follow" => {~w[Object Activity], []},
    "Ignore" => {~w[Object Activity], []},
    "Invite" => {~w[Object Activity], []},
    "Join" => {~w[Object Activity], []},
    "Leave" => {~w[Object Activity], []},
    "Like" => {~w[Object Activity], []},
    "Listen" => {~w[Object Activity], []},
    "Move" => {~w[Object Activity], []},
    "Offer" => {~w[Object Activity], []},
    "Question" => {~w[Object Activity], []},
    "Reject" => {~w[Object Activity], []},
    "Read" => {~w[Object Activity], []},
    "Remove" => {~w[Object Activity], []},
    "TentativeReject" => {~w[Object Activity], []},
    "TentativeAccept" => {~w[Object Activity], []},
    "Travel" => {~w[Object Activity], []},
    "Undo" => {~w[Object Activity], []},
    "Update" => {~w[Object Activity], []},
    "View" => {~w[Object Activity], []},
    "Article" => {~w[Object], []},
    "Audio" => {~w[Object], []},
    "Document" => {~w[Object], []},
    "Event" => {~w[Object], []},
    "Image" => {~w[Object], []},
    "Note" => {~w[Object], []},
    "Page" => {~w[Object], []},
    "Place" => {~w[Object], []},
    "Profile" => {~w[Object], []},
    "Relationship" => {~w[Object], []},
    "Tombstone" => {~w[Object], []},
    "Video" => {~w[Object], []},
    "Mention" => {~w[Link], []},
    "MoodleNet:Community" => {~w[Object Actor Group Collection], []},
    "MoodleNet:Collection" => {~w[Object Actor Group Collection], []},
    # "MoodleNet:EducationalResource" => {~w[Link], []},
    "MoodleNet:EducationalResource" => {~w[Object Page WebPage], []}
  }

  def parse(value) do
    # FIXME better errors: ParseError
    case ActivityPub.StringListType.cast(value) do
      {:ok, []} -> {:ok, ["Object"]}
      {:ok, list} -> {:ok, Enum.flat_map(list, &ancestors(&1)) |> Enum.uniq()}
      r -> r
    end
  end

  def all(), do: Map.keys(@type_map)

  for {type, {ancestors, _}} <- @type_map do
    def ancestors(unquote(type)), do: List.insert_at(unquote(ancestors), -1, unquote(type))
  end

  def ancestors(type) when is_binary(type), do: ["Object", type]
  def ancestors(list) when is_list(list), do: Enum.flat_map(list, &ancestors/1) |> Enum.uniq()

  for {type, {_, aspects}} <- @type_map do
    def aspects(unquote(type)), do: unquote(aspects)
  end

  def aspects(list) when is_list(list), do: Enum.flat_map(list, &aspects/1) |> Enum.uniq()
  def aspects(_), do: []
end
