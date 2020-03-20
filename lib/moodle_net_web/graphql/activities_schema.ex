# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.ActivitiesSchema do
  use Absinthe.Schema.Notation
  alias MoodleNetWeb.GraphQL.{
    ActivitiesResolver,
    CommonResolver,
    UsersResolver,
  }
  alias MoodleNet.Collections.Collection
  alias MoodleNet.Flags.Flag
  alias MoodleNet.Follows.Follow
  alias MoodleNet.Likes.Like
  alias MoodleNet.Communities.Community
  alias MoodleNet.Resources.Resource
  alias MoodleNet.Threads.Comment
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
    field :is_public, non_null(:boolean) do
      resolve &CommonResolver.is_public_edge/3
    end

    @desc "When the activity was created"
    field :created_at, non_null(:string) do
      resolve &CommonResolver.created_at_edge/3
    end

    @desc "The user who performed the activity"
    field :user, :user do
      resolve &UsersResolver.creator_edge/3
    end

    @desc "The object of the user's verbing"
    field :context, :activity_context do
      resolve &ActivitiesResolver.context_edge/3
    end
  end

  @desc "Something a user does, in past tense"
  enum :activity_verb, values: ["created", "updated"]

  union :activity_context do
    description("Activity object")
    types([:community, :collection, :resource, :comment, :flag, :follow, :like, :user])
    resolve_type(fn
      %Collection{}, _ -> :collection
      %Comment{},    _ -> :comment
      %Community{},  _ -> :community
      %Resource{},   _ -> :resource
      %Flag{},     _   -> :flag
      %Follow{},     _ -> :follow
      %Like{},       _ -> :like
      %User{},       _ -> :user
    end)
  end

  object :activities_page do
    field :page_info, :page_info
    field :edges, list_of(:activity)
    field :total_count, non_null(:integer)
  end

end
