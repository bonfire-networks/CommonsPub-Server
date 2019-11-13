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
  alias MoodleNetWeb.GraphQL.{
    CollectionsResolver,
    CommonResolver,
    CommentsResolver,
    CommunitiesResolver,
    LocalisationResolver,
    UsersResolver,
  }

  object :communities_queries do

    @desc "Get list of communities, most followed first"
    field :communities, :communities_nodes do
      arg :limit, :integer
      arg :before, :string
      arg :after, :string
      resolve &CommunitiesResolver.communities/2
    end

    @desc "Get a community"
    field :community, :community do
      arg :community_id, non_null(:string)
      resolve &CommunitiesResolver.community/2
    end

  end

  object :communities_mutations do

    @desc "Create a community"
    field :create_community, :community do
      arg :community, non_null(:community_input)
      resolve &CommunitiesResolver.create_community/2
    end

    @desc "Update a community"
    field :update_community, :community do
      arg :community_id, non_null(:string)
      arg :community, non_null(:community_input)
      resolve &CommunitiesResolver.update_community/2
    end

  end

  object :community do
    @desc "An instance-local UUID identifying the user"
    field :id, :string
    @desc "A url for the community, may be to a remote instance"
    field :canonical_url, :string
    @desc "An instance-unique identifier shared with users and collections"
    field :preferred_username, :string

    @desc "A name field"
    field :name, :string
    @desc "Possibly biographical information"
    field :summary, :string
    @desc "An avatar url"
    field :icon, :string
    @desc "A header background image url"
    field :image, :string

    @desc "Whether the community is local to the instance"
    field :is_local, :boolean
    @desc "Whether the community has a public profile"
    field :is_public, :boolean
    @desc "Whether an instance admin has disabled the community"
    field :is_disabled, :boolean

    @desc "When the community was created"
    field :created_at, :string
    @desc "When the community was last updated"
    field :updated_at, :string
    @desc """
    When the community or a resource or collection in it was last
    updated or a thread or a comment was created or updated
    """
    field :last_activity, :string do
      resolve &CommunitiesResolver.last_activity/3
    end

    @desc "The current user's follow of the community, if any"
    field :my_follow, :follow do
      resolve &CommonResolver.my_follow/3
    end
 
    @desc "The primary language the community speaks"
    field :primary_language, :language do
      resolve &LocalisationResolver.primary_language/3
    end

    @desc "The user who created the community"
    field :creator, :user do
      resolve &UsersResolver.creator/3
    end

    @desc "The communities a user has joined, most recently joined first"
    field :collections, :collections_edges do
      arg :limit, :integer
      arg :before, :string
      arg :after, :string
      resolve &CollectionsResolver.collections/3
    end

    @desc """
    Threads started on the community, in most recently updated
    order. Does not include threads started on collections or
    resources
    """
    field :threads, :threads_edges do
      arg :limit, :integer
      arg :before, :string
      arg :after, :string
      resolve &CommentsResolver.threads/3
    end

    @desc "Users following the community, most recently followed first"
    field :followers, :follows_edges do
      arg :limit, :integer
      arg :before, :string
      arg :after, :string
      resolve &CommonResolver.followers/3
    end

    @desc "Activities for community moderators. Not available to plebs."
    field :inbox, :activities_edges do
      arg :limit, :integer
      arg :before, :string
      arg :after, :string
      resolve &CommunitiesResolver.inbox/3
    end

    @desc "Activities in the community, most recently created first"
    field :outbox, :activities_edges do
      arg :limit, :integer
      arg :before, :string
      arg :after, :string
      resolve &CommunitiesResolver.outbox/3
    end

  end

  object :communities_nodes do
    field :page_info, non_null(:page_info)
    field :nodes, list_of(:community)
    field :total_count, non_null(:integer)
  end

  object :communities_edges do
    field :page_info, non_null(:page_info)
    field :edges, list_of(:community)
    field :total_count, non_null(:integer)
  end

  object :communities_edge do
    field :cursor, non_null(:string)
    field :node, :community
  end

  input_object :community_input do
    field :preferred_username, non_null(:string)
    field :primary_language_id, :string
    field :name, non_null(:string)
    field :summary, non_null(:string)
    field :icon, :string
    field :image, :string
  end

end
