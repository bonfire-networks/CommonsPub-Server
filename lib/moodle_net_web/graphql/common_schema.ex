# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.CommonSchema do
  use Absinthe.Schema.Notation

  alias MoodleNetWeb.GraphQL.CommonResolver

  union :any_context do
    description("Any type of known object")
    # TODO: autogenerate
    types([
      :community,
      :collection,
      :resource,
      :comment,
      :flag,
      :follow,
      :like,
      :user,
      :organisation,
      :spatial_thing,
      :intent
    ])

    resolve_type(fn
      %MoodleNet.Users.User{}, _ -> :user
      %MoodleNet.Communities.Community{}, _ -> :community
      %MoodleNet.Collections.Collection{}, _ -> :collection
      %MoodleNet.Resources.Resource{}, _ -> :resource
      %MoodleNet.Threads.Thread{}, _ -> :thread
      %MoodleNet.Threads.Comment{}, _ -> :comment
      %MoodleNet.Follows.Follow{}, _ -> :follow
      %MoodleNet.Likes.Like{}, _ -> :like
      %MoodleNet.Flags.Flag{}, _ -> :flag
      %MoodleNet.Features.Feature{}, _ -> :feature
      %Organisation{}, _ -> :organisation
      %Geolocation{}, _ -> :spatial_thing
      # %ValueFlows.Agent.Agents{}, _ -> :agent
      # %ValueFlows.Agent.People{}, _ -> :person
      # %ValueFlows.Agent.Organizations{}, _ -> :organization
      %ValueFlows.Planning.Intent{}, _ -> :intent
    end)
  end

  object :common_queries do
  end

  object :common_mutations do
    @desc "Delete more or less anything"
    field :delete, :any_context do
      arg(:context_id, non_null(:string))
      resolve(&CommonResolver.delete/2)
    end
  end

  @desc "Cursors for pagination"
  object :page_info do
    field(:start_cursor, list_of(non_null(:cursor)))
    field(:end_cursor, list_of(non_null(:cursor)))
    field(:has_previous_page, :boolean)
    field(:has_next_page, :boolean)
  end
end
