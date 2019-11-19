# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.ActivitiesSchema do
  use Absinthe.Schema.Notation
  alias MoodleNetWeb.GraphQL.{
    ActivitiesResolver,
    CollectionsResolver,
    UsersResolver,
  }
  alias MoodleNet.Collections.Collection
  alias MoodleNet.Comments.Comment
  alias MoodleNet.Communities.Community
  alias MoodleNet.Resources.Resource
  alias MoodleNet.Users.User

  object :activities_queries do

    field :activity, :activity do
      arg :activity_id, non_null(:string)
      resolve &ActivitiesResolver.activity/2
    end

  end

  @desc "An event that appears in a feed"
  object :activity do
    @desc "An instance-local UUID identifying the activity"
    field :id, non_null(:string)
    @desc "A url for the like, may be to a remote instance"
    field :canonical_url, :string

    @desc "The verb describing the activity"
    field :verb, non_null(:activity_verb)

    @desc "Whether the activity is local to the instance"
    field :is_local, non_null(:boolean)
    @desc "Whether the activity is public"
    field :is_public, non_null(:boolean)

    @desc "When the activity was created"
    field :created_at, non_null(:string)

    @desc "The user who performed the activity"
    field :user, non_null(:user) do
      resolve &ActivitiesResolver.user/3
    end

    @desc "The object of the user's verbing"
    field :context, non_null(:activity_context) do
      resolve &ActivitiesResolver.context/3
    end
  end

  @desc "Something a user does, in past tense"
  enum :activity_verb, values: ["created", "updated"]

  union :activity_context do
    description("Activity object")
    types([:community, :collection, :resource, :comment])
    resolve_type(fn
      %Collection{}, _ -> :collection
      %Comment{},    _ -> :comment
      %Community{},  _ -> :community
      %Resource{},   _ -> :resource
    end)
  end

  object :activities_nodes do
    field :page_info, :page_info
    field :nodes, non_null(list_of(:activity))
    field :total_count, non_null(:integer)
  end

  object :activities_edges do
    field :page_info, :page_info
    field :edges, non_null(list_of(:activities_edge))
    field :total_count, non_null(:integer)
  end

  object :activities_edge do
    field :cursor, non_null(:string)
    field :node, non_null(:activity)
  end

end
