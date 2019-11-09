# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.ResourcesSchema do
  @moduledoc """
  GraphQL resource fields, associations, queries and mutations.
  """
  use Absinthe.Schema.Notation

  alias MoodleNetWeb.GraphQL.ResourcesResolver

  object :resources_queries do

    @desc "Get a resource"
    field :resource, :resource do
      arg :resource_id, non_null(:string)
      resolve &ResourcesResolver.fetch/2
    end

  end

  object :resources_mutations do

    @desc "Create a resource"
    field :create_resource, type: :resource do
      arg :collection_id, non_null(:string)
      arg :resource, non_null(:resource_input)
      resolve &ResourcesResolver.create/2
    end

    @desc "Update a resource"
    field :update_resource, type: :resource do
      arg :resource_id, non_null(:string)
      arg :resource, non_null(:resource_input)
      resolve &ResourcesResolver.update/2
    end

    @desc "Delete a resource"
    field :delete_resource, type: :boolean do
      arg :resource_id, non_null(:string)
      resolve &CommonResolver.delete/2
    end

    @desc "Copy a resource"
    field :copy_resource, type: non_null(:resource) do
      arg :resource_id, non_null(:string)
      arg :collection_id, non_null(:string)
      resolve &ResourcesResolver.copy/2
    end

  end

  object :resource do
    @desc "An instance-local UUID identifying the user"
    field :id, :string

    @desc "A name field"
    field :name, :string
    @desc "Possibly biographical information"
    field :summary, :string
    @desc "An avatar url"
    field :icon, :string
    @desc "A link to an external resource"
    field :url, :string

    @desc "When the collection was created"
    field :created_at, :string
    @desc "When the collection was last updated"
    field :updated_at, :string
    @desc """
    When the resource was last updated or a thread or a comment on it
    was created or updated
    """
    field :last_activity, :string

    @desc "Whether the user is local to the instance"
    field :is_local, :boolean
    @desc "Whether the user has a public profile"
    field :is_public, :boolean
    @desc "Whether an instance admin has hidden the resource"
    field :is_hidden, :boolean

    @desc "The current user's like of the resource, if any"
    field :my_like, :like do
      resolve &CommonResolver.my_like/3
    end

    @desc "The user who created the resource"
    field :creator, :user do
      resolve &CommonResolver.creator/3
    end

    @desc "The collection this resource is a part of"
    field :collection, :collection do
      resolve &ResourcesResolver.collection/3
    end

    @desc "Languages the resources is available in"
    field :languages, non_null(:resource_languages_connection) do
      arg :limit, :integer
      arg :before, :string
      arg :after, :string
      resolve &ResourceResolver.languages/3
    end

    @desc "Users who like the resource, most recently liked first"
    field :likes, non_null(:resource_likes_connection) do
      arg :limit, :integer
      arg :before, :string
      arg :after, :string
      resolve &CommonResolver.likes/3
    end

    @desc "Flags users have made about the resource, most recently created first"
    field :flags, non_null(:resource_flags_connection) do
      arg :limit, :integer
      arg :before, :string
      arg :after, :string
      resolve &CommonResolver.flags/3
    end

    @desc "Tags users have applied to the resource, most recently created first"
    field :tags, non_null(:resource_flags_connection) do
      arg :limit, :integer
      arg :before, :string
      arg :after, :string
      resolve &CommonResolver.tags/3
    end

    @desc "What license is it available under?"
    field :license, :string

    # @desc "approx reading time in minutes"
    # field :time_required, :integer
    # @desc "free text"
    # field :typical_age_range, :string
    # @desc "??? Something about link aliasing"
    # field :same_as, :string
    # @desc "Can you use this without an institutional email or such"
    # field :public_access, :boolean
    # @desc "Can you use it without paying?"
    # field :free_access, :boolean
    # @desc "???"
    # field :learning_resource_type, :string
    # @desc "???"
    # field :educational_use, list_of(non_null(:string))

  end

  object :resource_likes_connection do
    field :page_info, non_null(:page_info)
    field :edges, list_of(:resource_likes_edge)
    field :total_count, non_null(:integer)
  end

  object :resource_likes_edge do
    field :cursor, non_null(:string)
    field :node, :like
  end

  object :resource_flags_connection do
    field :page_info, non_null(:page_info)
    field :edges, list_of(:resource_flags_edge)
    field :total_count, non_null(:integer)
  end

  object :resource_flags_edge do
    field :cursor, non_null(:string)
    field :node, :flag
  end

  input_object :resource_input do
    field :name, :string
    field :content, :string
    field :summary, :string
    field :icon, :string
    field :languages, list_of(:string)
    field :url, :string
    field :license, :string
  end

end
