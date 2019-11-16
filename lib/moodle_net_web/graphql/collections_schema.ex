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
    CommentsResolver,
    CommunitiesResolver,
    CommonResolver,
    LocalisationResolver,
    ResourcesResolver,
    UsersResolver,
  }

  object :collections_queries do

    @desc "Get list of collections, most recent activity first"
    field :collections, non_null(:collections_nodes) do
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
    field :create_collection, :collection do
      arg :community_id, non_null(:string)
      arg :collection, non_null(:collection_input)
      resolve &CollectionsResolver.create_collection/2
    end

    @desc "Update a collection"
    field :update_collection, :collection do
      arg :collection_id, non_null(:string)
      arg :collection, non_null(:collection_input)
      resolve &CollectionsResolver.update_collection/2
    end

  end

  @desc """
  A collection is the home of resources and discussion threads within a community
  """
  object :collection do
    @desc "An instance-local UUID identifying the user"
    field :id, non_null(:string)
    @desc "A url for the collection, may be to a remote instance"
    field :canonical_url, :string
    @desc "An instance-unique identifier shared with users and communities"
    field :preferred_username, non_null(:string)

    @desc "A name field"
    field :name, non_null(:string)
    @desc "Possibly biographical information"
    field :summary, :string
    @desc "An avatar url"
    field :icon, :string

    @desc "Whether the collection is local to the instance"
    field :is_local, non_null(:boolean)
    @desc "Whether the collection is public"
    field :is_public, non_null(:boolean)
    @desc "Whether an instance admin has hidden the collection"
    field :is_disabled, non_null(:boolean)

    @desc "When the collection was created"
    field :created_at, non_null(:string)
    @desc "When the collection was last updated"
    field :updated_at, non_null(:string)
    @desc """
    When the collection or a resource in it was last updated or a
    thread or a comment was created or updated
    """
    field :last_activity, non_null(:string) do
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

    # @desc "The primary language the community speaks"
    # field :primary_language, :language do
    #   resolve &LocalisationResolver.primary_language/3
    # end

    @desc "The user who created the collection"
    field :creator, non_null(:user) do
      resolve &UsersResolver.creator/3
    end

    @desc "The community the collection belongs to"
    field :community, non_null(:community) do
      resolve &CommunitiesResolver.community/3
    end

    @desc "The resources in the collection, most recently created last"
    field :resources, non_null(:resources_connection) do
      arg :limit, :integer
      arg :before, :string
      arg :after, :string
      resolve &ResourcesResolver.resources/3
    end

    @desc "Subscriptions users have to the collection"
    field :followers, non_null(:follows_connection) do
      arg :limit, :integer
      arg :before, :string
      arg :after,  :string
      resolve &CommonResolver.followers/3
    end

    @desc "Likes users have given the collection"
    field :likes, non_null(:likes_connection) do
      arg :limit, :integer
      arg :before, :string
      arg :after, :string
      resolve &CommonResolver.likes/3
    end

    @desc "Flags users have made about the collection, most recently created first"
    field :flags, non_null(:flags_connection) do
      arg :limit, :integer
      arg :before, :string
      arg :after, :string
      resolve &CommonResolver.flags/3
    end

    # @desc "Tags users have applied to the resource, most recently created first"
    # field :tags, :taggings_connection do
    #   arg :limit, :integer
    #   arg :before, :string
    #   arg :after, :string
    #   resolve &CommonResolver.taggings/3
    # end

    @desc """
    The threads created on the collection, most recently created
    first. Does not include threads created on resources.
    """
    field :threads, non_null(:threads_connection) do
      arg :limit, :integer
      arg :before, :string
      arg :after, :string
      resolve &CommentsResolver.threads/3
    end

    @desc "Activities on the collection, most recent first"
    field :outbox, non_null(:activities_connection) do
      arg :limit, :integer
      arg :before, :string
      arg :after, :string
      resolve &CollectionsResolver.outbox/3
    end

  end

  object :collections_nodes do
    field :page_info, :page_info
    field :nodes, non_null(list_of(:collection))
    field :total_count, non_null(:integer)
  end

  object :collections_connection do
    field :page_info, :page_info
    field :edges, non_null(list_of(:collections_edge))
    field :total_count, non_null(:integer)
  end

  object :collections_edge do
    field :cursor, non_null(:string)
    field :node, non_null(:collection)
  end

  input_object :collection_input do
    field :preferred_username, non_null(:string)
    field :name, non_null(:string)
    field :summary, :string
    field :icon, :string
    # field :primary_language_id, :string
  end

end
