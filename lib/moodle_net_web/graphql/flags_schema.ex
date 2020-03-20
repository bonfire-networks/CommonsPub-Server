# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.FlagsSchema do

  use Absinthe.Schema.Notation
  alias MoodleNet.Collections.Collection
  alias MoodleNet.Communities.Community
  alias MoodleNet.Resources.Resource
  alias MoodleNet.Threads.Comment
  alias MoodleNet.Users.User
  alias MoodleNetWeb.GraphQL.{CommonResolver, FlagsResolver, UsersResolver}

  object :flags_queries do

    field :flag, :flag do
      arg :flag_id, non_null(:string)
      resolve &FlagsResolver.flag/2
    end

  end

  object :flags_mutations do

    @desc "Flag a user, community, collection, resource or comment, returning the flag"
    field :create_flag, :flag do
      arg :context_id, non_null(:string)
      arg :message, non_null(:string)
      resolve &FlagsResolver.create_flag/2
    end

  end

  @desc "A report about objectionable content"
  object :flag do
    @desc "An instance-local UUID identifying the flag"
    field :id, non_null(:string)
    @desc "A url for the flag, may be to a remote instance"
    field :canonical_url, :string

    @desc "The reason for flagging"
    field :message, non_null(:string)
    @desc "Is the flag considered dealt with by the instance moderator?"
    field :is_resolved, non_null(:boolean) do
      resolve &FlagsResolver.is_resolved_edge/3
    end

    @desc "Whether the flag is local to the instance"
    field :is_local, non_null(:boolean)
    # @desc "Whether the flag is public"
    # field :is_public, non_null(:boolean) do
    #   resolve &CommonResolver.is_public/3
    # end

    @desc "When the flag was created"
    field :created_at, non_null(:string) do
      resolve &CommonResolver.created_at_edge/3
    end
    @desc "When the flag was updated"
    field :updated_at, non_null(:string)

    @desc "The user who flagged"
    field :creator, :user do
      resolve &UsersResolver.creator_edge/3
    end

    @desc "The thing that is being flagged"
    field :context, :flag_context do
      resolve &CommonResolver.context_edge/3
    end

    # @desc "An optional thread to discuss the flag"
    # field :thread, :liked do
    #   resolve &CommonResolver.like_liked/3
    # end
  end

  union :flag_context do
    description "A thing that can be flagged"
    types [:collection, :comment, :community, :resource, :user]
    resolve_type fn
      %Collection{}, _ -> :collection
      %Comment{},    _ -> :comment
      %Community{},  _ -> :community
      %Resource{},   _ -> :resource
      %User{},       _ -> :user
    end
  end
  
  object :flags_page do
    field :page_info, :page_info
    field :edges, non_null(list_of(:flag))
    field :total_count, non_null(:integer)
  end

end
