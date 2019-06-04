# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule ActivityPub.Types do
  @moduledoc """
  Contains the conversion table for Activities/Objects, used to detect the `ActivityPub.Entity` type and infer the `ActivityPub.Aspect`(s) implemented by the `Entity`.

  """

  alias ActivityPub.{ObjectAspect, ActorAspect, ActivityAspect, CollectionAspect}

  alias ActivityPub.BuildError

  @type_map %{
    "Link" => {[], []},
    "Object" => {[], [ObjectAspect]},
    "Collection" => {~w[Object], [CollectionAspect]},
    "OrderedCollection" => {~w[Object Collection], []},
    "CollectionPage" => {~w[Object Collection], []},
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
    "MoodleNet:Community" => {~w[Object Actor Group], [MoodleNet.AP.CommunityAspect]},
    "MoodleNet:Collection" => {~w[Object Actor Group], [MoodleNet.AP.CollectionAspect]},
    "MoodleNet:EducationalResource" => {~w[Object Page WebPage], [MoodleNet.AP.ResourceAspect]}
  }

  def build(value) do
    case ActivityPub.StringListType.cast(value) do
      {:ok, []} -> {:ok, ["Object"]}
      {:ok, list} -> {:ok, Enum.flat_map(list, &ancestors(&1)) |> Enum.uniq()}
      :error -> %BuildError{path: ["type"], value: value, message: "is invalid"}
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
