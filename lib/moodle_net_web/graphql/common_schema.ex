# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.CommonSchema do
  use Absinthe.Schema.Notation
  alias MoodleNet.Flags.Flag
  alias MoodleNet.Follows.Follow
  alias MoodleNet.Features.Feature
  alias MoodleNet.Likes.Like
  alias MoodleNet.Collections.Collection
  alias MoodleNet.Communities.Community
  alias MoodleNet.Resources.Resource
  alias MoodleNet.Threads.{Comment, Thread}
  alias MoodleNet.Users.User
  alias MoodleNetWeb.GraphQL.CommonResolver

  object :common_queries do

  end

  object :common_mutations do

    @desc "Delete more or less anything"
    field :delete, :delete_context do
     arg :context_id, non_null(:string)
      resolve &CommonResolver.delete/2
    end

  end


  @desc "Cursors for pagination"
  object :page_info do
    field :start_cursor, non_null(list_of(non_null(:cursor)))
    field :end_cursor, non_null(list_of(non_null(:cursor)))
    field :has_previous_page, non_null(:boolean)
    field :has_next_page, non_null(:boolean)
  end

  union :delete_context do
    description "A thing that can be deleted"
    types [
      :collection, :comment, :community, :feature,
      :follow, :flag, :like, :resource, :thread, :user,
    ]
    resolve_type fn
      %Collection{}, _ -> :collection
      %Comment{},    _ -> :comment
      %Community{},  _ -> :community
      %Feature{},    _ -> :feature
      %Follow{},     _ -> :follow
      %Flag{},       _ -> :flag
      %Like{},       _ -> :like
      %Resource{},   _ -> :resource
      %Thread{},     _ -> :thread
      %User{},       _ -> :user
    end
  end

end
