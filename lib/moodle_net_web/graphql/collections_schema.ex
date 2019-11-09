# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.CollectionsSchema do
  @moduledoc """
  GraphQL collection fields, associations, queries and mutations.
  """
  use Absinthe.Schema.Notation
  alias MoodleNetWeb.GraphQL.{CollectionsResolver, CommonResolver}

  object :collections_queries do

    @desc "Get list of collections, most recent activity first"
    field :collections, :collection_page do
      arg :limit, :integer
      arg :before, :string
      arg :after, :string
      resolve &CollectionsResolver.list/2
    end

    @desc "Get a collection"
    field :collection, :collection do
      arg :collection_id, non_null(:string)
      resolve &CollectionsResolver.fetch/2
    end
  end

  object :collections_mutations do

    @desc "Create a collection"
    field :create_collection, type: :collection do
      arg :community_id, non_null(:string)
      arg :collection, non_null(:collection_input)
      resolve &CollectionsResolver.create/2
    end

    @desc "Update a collection"
    field :update_collection, type: :collection do
      arg :collection_id, non_null(:integer)
      arg :collection, non_null(:collection_input)
      resolve &CollectionsResolver.update/2
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
    field :last_activity, :string

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
      resolve &CommonResolver.primary_language/3
    end

    @desc "The user who created the collection"
    field :creator, :user do
      resolve &CommonResolver.creator/3
    end

    @desc "The community the collection belongs to"
    field :community, :community do
      resolve &CollectionsResolver.community/3
    end 

    @desc "The resources in the collection, most recently created last"
    field :resources, :collection_resources_connection do
      arg :limit, :integer
      arg :before, :string
      arg :after, :string
      resolve &CollectionsResolver.resources/3
    end

    @desc """
    The threads created on the collection, most recently created
    first.  Does not include threads created on resources.
    """
    field :threads, :collection_threads_connection do
      arg :limit, :integer
      arg :before, :string
      arg :after, :string
      resolve &CommonResolver.threads/3
    end

    @desc "Users following the collection, most recently followed first"
    field :followers, :collection_followers_connection do
      arg :limit, :integer
      arg :before, :string
      arg :after,  :string
      resolve &CommonResolver.followers/3
    end

    @desc "Users who like the collection, most recently liked first"
    field :likes, :collection_likes_connection do
      arg :limit, :integer
      arg :before, :string
      arg :after, :string
      resolve &CommonResolver.likes/3
    end

    @desc "Flags users have made about the collection, most recently created first"
    field :flags, :collection_flags_connection do
      arg :limit, :integer
      arg :before, :string
      arg :after, :string
      resolve &CommonResolver.flags/3
    end

    @desc "Tags users have applied to the resource, most recently created first"
    field :tags, non_null(:resource_tags_connection) do
      arg :limit, :integer
      arg :before, :string
      arg :after, :string
      resolve &CommonResolver.tags/3
    end

  end

  object :collection_page do
    field :page_info, non_null(:page_info)
    field :nodes, list_of(:collection)
    field :total_count, non_null(:integer)
  end

  object :collection_followers_connection do
    field :page_info, non_null(:page_info)
    field :edges, list_of(:collection_followers_edge)
    field :total_count, non_null(:integer)
  end

  object :collection_followers_edge do
    field :cursor, non_null(:string)
    field :node, :follow
  end

  object :collection_resources_connection do
    field :page_info, non_null(:page_info)
    field :edges, list_of(:collection_resources_edge)
    field :total_count, non_null(:integer)
  end

  object :collection_resources_edge do
    field :cursor, non_null(:string)
    field :node, :resource
  end

  object :collection_threads_connection do
    field :page_info, non_null(:page_info)
    field :edges, list_of(:collection_threads_edge)
    field :total_count, non_null(:integer)
  end

  object :collection_threads_edge do
    field :cursor, non_null(:string)
    field :node, :comment
  end

  object :collection_likes_connection do
    field :page_info, non_null(:page_info)
    field :edges, list_of(:collection_likes_edge)
    field :total_count, non_null(:integer)
  end

  object :collection_likes_edge do
    field :cursor, non_null(:string)
    field :node, :user
  end

  object :collection_flags_connection do
    field :page_info, non_null(:page_info)
    field :edges, list_of(:collection_flags_edge)
    field :total_count, non_null(:integer)
  end

  object :collection_flags_edge do
    field :cursor, non_null(:string)
    field :node, :user
    field :reason, :string
  end

  object :collection_tags_connection do
    field :page_info, non_null(:page_info)
    field :edges, list_of(:collection_tags_edge)
    field :total_count, non_null(:integer)
  end

  object :collection_tags_edge do
    field :cursor, non_null(:string)
    field :node, :tag
  end

  object :collection_outbox_connection do
    field :page_info, non_null(:page_info)
    field :edges, list_of(:collection_activities_edge)
    field :total_count, non_null(:integer)
  end

  object :collection_activities_edge do
    field :cursor, non_null(:string)
    field :node, :activity
  end

  input_object :collection_input do
    field :name, non_null(:string)
    field :summary, non_null(:string)
    field :preferred_username, non_null(:string)
    field :icon, :string
    field :primary_language_id, :string
  end

end
