# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.LikesSchema do

  use Absinthe.Schema.Notation
  alias MoodleNet.Collections.Collection
  alias MoodleNet.Communities.Community
  alias MoodleNet.Resources.Resource
  alias MoodleNet.Threads.Comment
  alias MoodleNet.Users.User
  alias MoodleNetWeb.GraphQL.{CommonResolver, LikesResolver, UsersResolver}

  object :likes_queries do

    @desc "Fetch a like by ID"
    field :like, :like do
      arg :like_id, non_null(:string)
      resolve &LikesResolver.like/2
    end

  end

  object :likes_mutations do

    @desc "Like a comment, collection, or resource returning the like"
    field :create_like, :like do
      arg :context_id, non_null(:string)
      resolve &LikesResolver.create_like/2
    end

  end

  @desc "A record that a user likes a thing"
  object :like do
    @desc "An instance-local UUID identifying the like"
    field :id, non_null(:string)
    @desc "A url for the like, may be to a remote instance"
    field :canonical_url, :string
    
    @desc "Whether the like is local to the instance"
    field :is_local, non_null(:boolean)
    @desc "Whether the like is public"
    field :is_public, non_null(:boolean) do
      resolve &CommonResolver.is_public_edge/3
    end

    @desc "When the like was created"
    field :created_at, non_null(:string) do
      resolve &CommonResolver.created_at_edge/3
    end
    @desc "When the like was last updated"
    field :updated_at, non_null(:string)

    @desc "The user who liked"
    field :creator, :user do
      resolve &UsersResolver.creator_edge/3
    end

    @desc "The thing that is liked"
    field :context, :like_context do
      resolve &CommonResolver.context_edge/3
    end
  end

  union :like_context do
    description "A thing which can be liked"
    types [:collection, :comment, :community, :resource, :user]
    resolve_type fn
      %Collection{}, _ -> :collection
      %Comment{},    _ -> :comment
      %Community{},  _ -> :community
      %Resource{},   _ -> :resource
      %User{},       _ -> :user
    end
  end

  object :likes_edges do
    field :page_info, :page_info
    field :edges, non_null(list_of(:likes_edge))
    field :total_count, non_null(:integer)
  end

  object :likes_edge do
    field :cursor, non_null(:string)
    field :node, non_null(:like)
  end

end
