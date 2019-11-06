# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.CommunitiesSchema do
  @moduledoc """
  GraphQL community fields, associations, queries and mutations.
  """
  use Absinthe.Schema.Notation

  alias MoodleNet.Collections.Collection
  alias MoodleNet.Comments.Comment
  alias MoodleNet.Resources.Resource
  alias MoodleNetWeb.GraphQL.CommunitiesResolver

  object :communities_queries do

    @desc "Get list of communities"
    field :communities, :community_page do
      arg :limit, :integer
      arg :before, :string
      arg :after, :string
      resolve &CommunitiesResolver.list/2
    end

    @desc "Get a community"
    field :community, :community do
      arg :community_id, non_null(:string)
      resolve &CommunitiesResolver.fetch/2
    end
  end

  object :communities_mutations do

    @desc "Create a community"
    field :create_community, type: :community do
      arg :community, non_null(:community_input)
      resolve &CommunitiesResolver.create/2
    end

    @desc "Update a community"
    field :update_community, type: :community do
      arg :community_id, non_null(:string)
      arg :community, non_null(:community_input)
      resolve &CommunitiesResolver.update/2
    end

    @desc "Delete a community"
    field :delete_community, type: :boolean do
      arg :community_id, non_null(:string)
      resolve &CommunitiesResolver.delete/2
    end

  end

  object :community do
    field :id, :string
    field :name, :string
    field :summary, :string
    field :preferred_username, :string
    field :icon, :string
    field :image, :string
    field :primary_language, :language

    field :local, :boolean
    field :public, :boolean

    field :creator, :user do
      resolve &CommunitiesResolver.creator/3
    end

    field :collections, :community_collections_connection do
      arg :limit, :integer
      arg :before, :string
      arg :after, :string
      resolve &CommunitiesResolver.collections/3
    end

    field :threads, :community_threads_connection do
      arg :limit, :integer
      arg :before, :string
      arg :after, :string
      resolve &CommunitiesResolver.threads/3
    end

    field :followers, :community_followers_connection do
      arg :limit, :integer
      arg :before, :string
      arg :after, :string
      resolve &CommonResolver.followers/3
    end

    field :inbox, :community_activities_connection do
      arg :limit, :integer
      arg :before, :string
      arg :after, :string
      resolve &CommunitiesResolver.inbox/3
    end

    field :published, :string
    field :updated, :string

    field :i_follow, non_null(:boolean) do
      resolve &CommonResolver.i_follow/3
    end
 
    field :i_like, non_null(:boolean) do
      resolve &CommonResolver.i_like/3
    end
 end

  object :community_page do
    field :page_info, non_null(:page_info)
    field :nodes, list_of(:community)
    field :total_count, non_null(:integer)
  end

  object :community_collections_connection do
    field :page_info, non_null(:page_info)
    field :edges, list_of(:community_collections_edge)
    field :total_count, non_null(:integer)
  end

  object :community_collections_edge do
    field :cursor, non_null(:integer)
    field :node, :collection
  end

  object :community_threads_connection do
    field :page_info, non_null(:page_info)
    field :edges, list_of(:community_threads_edge)
    field :total_count, non_null(:integer)
  end

  object :community_threads_edge do
    field :cursor, non_null(:integer)
    field :node, :thread
  end

  object :community_followers_connection do
    field :page_info, non_null(:page_info)
    field :edges, list_of(:community_followers_edge)
    field :total_count, non_null(:integer)
  end

  object :community_followers_edge do
    field :cursor, non_null(:integer)
    field :node, :user
  end

  object :community_activities_connection do
    field :page_info, non_null(:page_info)
    field :edges, list_of(:community_activities_edge)
    field :total_count, non_null(:integer)
  end

  object :community_activities_edge do
    field :cursor, non_null(:integer)
    field :node, :activity
  end

  input_object :community_input do
    field :primary_language_id, non_null(:string)
    field :name, non_null(:string)
    field :summary, non_null(:string)
    field :preferred_username, non_null(:string)
    field :icon, :string
    field :image, :string
  end

end
