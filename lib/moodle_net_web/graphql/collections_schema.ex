# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.CollectionsSchema do
  @moduledoc """
  GraphQL collection fields, associations, queries and mutations.
  """
  use Absinthe.Schema.Notation
  alias MoodleNetWeb.GraphQL.{
    CollectionsResolver,
    CommonResolver,
    LocalisationResolver,
  }

  object :collections_queries do

    @desc "Get list of collections, most recent activity first"
    field :collections, :collections_nodes do
      arg :limit, :integer
      arg :before, :string
      arg :after, :string
      resolve &CollectionsResolver.collections/2
    end

    @desc "Get a collection"
    field :collection, :collection do
      arg :collection_id, non_null(:string)
      resolve &CollectionsResolver.collection/2
    end
  end

  object :collections_mutations do

    @desc "Create a collection"
    field :create_collection, type: :collection do
      arg :community_id, non_null(:string)
      arg :collection, non_null(:collection_input)
      resolve &CollectionsResolver.create_collection/2
    end

    @desc "Update a collection"
    field :update_collection, type: :collection do
      arg :collection_id, non_null(:integer)
      arg :collection, non_null(:collection_input)
      resolve &CollectionsResolver.update_collection/2
    end

  end

  @desc """
  A collection is the home of resources and discussion threads within a community
  """ 
  object :collection do
    @desc "An instance-local UUID identifying the user"
    field :id, :string
    @desc "A url for the collection, may be to a remote instance"
    field :canonical_url, :string
    @desc "An instance-unique identifier shared with users and communities"
    field :preferred_username, :string

    @desc "A name field"
    field :name, :string
    @desc "Possibly biographical information"
    field :summary, :string
    @desc "An avatar url"
    field :icon, :string

    @desc "Whether the collection is local to the instance"
    field :is_local, :boolean
    @desc "Whether the collection is public"
    field :is_public, :boolean
    @desc "Whether an instance admin has hidden the collection"
    field :is_hidden, :boolean

    @desc "When the collection was created"
    field :created_at, :string
    @desc "When the collection was last updated"
    field :updated_at, :string
    @desc """
    When the collection or a resource in it was last updated or a
    thread or a comment was created or updated
    """
    field :last_activity, :string do
      resolve &CollectionsResolver.last_activity/3
    end

    @desc "The current user's like of this collection, if any"
    field :my_like, :like do
      resolve &CommonResolver.my_like/3
    end

    @desc "The current user's follow of this collection, if any"
    field :my_follow, :follow do
      resolve &CommonResolver.my_follow/3
    end

    @desc "The primary language the community speaks"
    field :primary_language, :language do
      resolve &LocalisationResolver.primary_language/3
    end

    @desc "The user who created the collection"
    field :creator, :user do
      resolve &UsersResolver.creator/3
    end

    @desc "The community the collection belongs to"
    field :community, :community do
      resolve &CommunitiesResolver.community/3
    end 

    @desc "The resources in the collection, most recently created last"
    field :resources, :resources_edges do
      arg :limit, :integer
      arg :before, :string
      arg :after, :string
      resolve &ResourcesResolver.resources/3
    end

    @desc "Subscriptions users have to the collection"
    field :followers, :follows_edges do
      arg :limit, :integer
      arg :before, :string
      arg :after,  :string
      resolve &CommonResolver.followers/3
    end

    @desc "Likes users have given the collection"
    field :likes, :likes_edges do
      arg :limit, :integer
      arg :before, :string
      arg :after, :string
      resolve &CommonResolver.likes/3
    end

    @desc "Flags users have made about the collection, most recently created first"
    field :flags, :flags_edges do
      arg :limit, :integer
      arg :before, :string
      arg :after, :string
      resolve &CommonResolver.flags/3
    end

    @desc "Tags users have applied to the resource, most recently created first"
    field :tags, :taggings_edges do
      arg :limit, :integer
      arg :before, :string
      arg :after, :string
      resolve &CommonResolver.tags/3
    end

    @desc """
    The threads created on the collection, most recently created
    first. Does not include threads created on resources.
    """
    field :threads, :threads_edges do
      arg :limit, :integer
      arg :before, :string
      arg :after, :string
      resolve &CommentsResolver.threads/3
    end

    @desc "Activities on the collection, most recent first"
    field :outbox, :activities_edges do
      arg :limit, :integer
      arg :before, :string
      arg :after, :string
      resolve &CollectionsResolver.outbox/3
    end

  end

  object :collections_nodes do
    field :page_info, non_null(:page_info)
    field :nodes, list_of(:collection)
    field :total_count, non_null(:integer)
  end

  object :collections_edges do
    field :page_info, non_null(:page_info)
    field :edges, list_of(:collections_edge)
    field :total_count, non_null(:integer)
  end

  object :collections_edge do
    field :cursor, non_null(:string)
    field :node, :collection
  end

  input_object :collection_input do
    field :name, non_null(:string)
    field :summary, non_null(:string)
    field :preferred_username, non_null(:string)
    field :icon, :string
    field :primary_language_id, :string
  end

end
