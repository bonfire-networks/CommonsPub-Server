# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.FeaturesSchema do

  use Absinthe.Schema.Notation
  alias MoodleNet.Collections.Collection
  alias MoodleNet.Communities.Community
  alias MoodleNetWeb.GraphQL.{CommonResolver, FeaturesResolver, UsersResolver}

  object :features_queries do

    field :feature, :feature do
      arg :feature_id, non_null(:string)
      resolve &FeaturesResolver.feature/2
    end

  end

  object :features_mutations do

    @desc "Feature a community, or collection, returning the feature"
    field :create_feature, :feature do
      arg :context_id, non_null(:string)
      resolve &FeaturesResolver.create_feature/2
    end

  end

  @desc "A featured piece of content"
  object :feature do
    @desc "An instance-local UUID identifying the feature"
    field :id, non_null(:string)
    @desc "A url for the feature, may be to a remote instance"
    field :canonical_url, :string

    @desc "Whether the feature is local to the instance"
    field :is_local, non_null(:boolean)

    @desc "When the feature was created"
    field :created_at, non_null(:string) do
      resolve &CommonResolver.created_at_edge/3
    end

    @desc "The user who featured"
    field :creator, :user do
      resolve &UsersResolver.creator_edge/3
    end

    @desc "The thing that is being featured"
    field :context, non_null(:feature_context) do
      resolve &CommonResolver.context_edge/3
    end

  end

  union :feature_context do
    description "A thing that can be featured"
    types [:collection, :community]
    resolve_type fn
      %Collection{}, _ -> :collection
      %Community{},  _ -> :community
    end
  end

  object :features_nodes do
    field :page_info, :page_info
    field :nodes, non_null(list_of(:features_edge))
    field :total_count, non_null(:integer)
  end

  object :features_edges do
    field :page_info, :page_info
    field :edges, non_null(list_of(:features_edge))
    field :total_count, non_null(:integer)
  end

  object :features_edge do
    field :cursor, non_null(:string)
    field :node, non_null(:feature)
  end

end
