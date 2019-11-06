# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNetWeb.GraphQL.ActivitiesSchema do
  @moduledoc """
  GraphQL activity fields, associations, queries and mutations.
  """
  use Absinthe.Schema.Notation

  require ActivityPub.Guards, as: APG
  alias ActivityPub.SQL.Query
  alias MoodleNetWeb.GraphQL.ActivitiesResolver
  alias MoodleNetWeb.GraphQL.MoodleNetSchema, as: Resolver

  object :activity do
    field :id, :string
    field :published, :string
    field :type, non_null(list_of(non_null(:string)))
    field :activity_type, :string

    field :user, :user do
      resolve &ActivitiesResolver.user/3
    end

    field :object, :activity_object do
      resolve &ActivitiesResolver.object/3
    end
  end

  union :activity_object do
    description("Activity object")

    types([:community, :collection, :resource, :comment])

    resolve_type(fn
      e, _ when APG.has_type(e, "MoodleNet:Community") -> :community
      e, _ when APG.has_type(e, "MoodleNet:Collection") -> :collection
      e, _ when APG.has_type(e, "MoodleNet:EducationalResource") -> :resource
      e, _ when APG.has_type(e, "Note") -> :comment
    end)
  end

  object :generic_activity_page do
    field(:page_info, non_null(:page_info))
    field(:nodes, list_of(:activity))
    field(:total_count, non_null(:integer))
  end

  def local_activity_list(args, info), do: Resolver.to_page(:local_activity, args, info)

  def prepare([e | _] = list, fields) when APG.has_type(e, "Activity") do
    list
    |> Query.preload_assoc([object: {[:all], [:object]}])
    |> Enum.map(&prepare(&1, fields))
  end

  def prepare(e, _fields) when APG.has_type(e, "Activity") do
    e
    |> Query.preload_assoc([object: {[:all], [:object]}])
    |> prepare_activity_fields()
    |> Resolver.prepare_common_fields()
  end

  defp prepare_activity_fields(%{object: [object | _]} = e) do
    Map.put(e, :activity_type, resolve_activity_type(e, object))
  end

  defp prepare_activity_fields(%{object: []} = e) do
    e
  end

  defp resolve_activity_type(activity, object)
       when APG.has_type(activity, "Create") and APG.has_type(object, "MoodleNet:Community"),
       do: "CreateCommunity"

  defp resolve_activity_type(activity, object)
       when APG.has_type(activity, "Update") and APG.has_type(object, "MoodleNet:Community"),
       do: "UpdateCommunity"

  defp resolve_activity_type(activity, object)
       when APG.has_type(activity, "Create") and APG.has_type(object, "MoodleNet:Collection"),
       do: "CreateCollection"

  defp resolve_activity_type(activity, object)
       when APG.has_type(activity, "Update") and APG.has_type(object, "MoodleNet:Collection"),
       do: "UpdateCollection"

  defp resolve_activity_type(activity, object)
       when APG.has_type(activity, "Create") and
              APG.has_type(object, "MoodleNet:EducationalResource"),
       do: "CreateResource"

  defp resolve_activity_type(activity, object)
       when APG.has_type(activity, "Update") and
              APG.has_type(object, "MoodleNet:EducationalResource"),
       do: "UpdateResource"

  defp resolve_activity_type(activity, object)
       when APG.has_type(activity, "Create") and APG.has_type(object, "Note"),
       do: "CreateComment"

  defp resolve_activity_type(activity, object)
       when APG.has_type(activity, "Follow") and APG.has_type(object, "MoodleNet:Community"),
       do: "JoinCommunity"

  defp resolve_activity_type(activity, object)
       when APG.has_type(activity, "Follow") and APG.has_type(object, "MoodleNet:Collection"),
       do: "FollowCollection"

  defp resolve_activity_type(activity, object)
       when APG.has_type(activity, "Like") and APG.has_type(object, "MoodleNet:Collection"),
       do: "LikeCollection"

  defp resolve_activity_type(activity, object)
       when APG.has_type(activity, "Like") and
              APG.has_type(object, "MoodleNet:EducationalResource"),
       do: "LikeResource"

  defp resolve_activity_type(activity, object)
       when APG.has_type(activity, "Like") and APG.has_type(object, "Note"),
       do: "LikeComment"

  defp resolve_activity_type(activity, _object)
  when APG.has_type(activity, "Undo"), do: "Undo"

  defp resolve_activity_type(_, _), do: "UnknownActivity"
end
