# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule Taxonomy.GraphQL.TagsSchema do

  use Absinthe.Schema.Notation
  alias MoodleNetWeb.GraphQL.{CommonResolver}
  alias Taxonomy.GraphQL.{TagsResolver}

  object :tags_queries do

    @desc "Get list of tags we know about"
    field :tags, non_null(:tags_nodes) do
      arg :limit, :integer
      arg :before, :string
      arg :after, :string
      resolve &TagsResolver.tags/2
    end

    field :tag, :tag do
      arg :tag_id, non_null(:string)
      resolve &TagsResolver.tag/2
    end

  end

  object :tag do
    field(:id, :integer)
    field(:label, :string)
    field(:parent_id, :integer)
  end

  object :tags_nodes do
    field :page_info, non_null(:page_info)
    field :nodes, list_of(:tag)
    field :total_count, non_null(:integer)
  end

  object :tags_edges do
    field :page_info, non_null(:page_info)
    field :edges, list_of(:tags_edge)
    field :total_count, non_null(:integer)
  end

  object :tags_edge do
    field :cursor, non_null(:string)
    field :node, :tag
  end


#  @desc "A category is a grouping mechanism for tags"
#   object :tag_category do
#     @desc "An instance-local UUID identifying the category"
#     field :id, :string
#     @desc "A url for the category, may be to a remote instance"
#     field :canonical_url, :string

#     @desc "The name of the tag category"
#     field :name, :string

#     @desc "Whether the like is local to the instance"
#     field :is_local, :boolean
#     @desc "Whether the like is public"
#     field :is_public, :boolean

#     @desc "When the like was created"
#     field :created_at, :string do
#       resolve &CommonResolver.created_at/3
#     end

#     # @desc "The current user's follow of the category, if any"
#     # field :my_follow, :follow do
#     #   resolve &CommonResolver.my_follow/3
#     # end

#     @desc "The tags in the category, most recently created first"
#     field :tags, :tags_edges do
#       arg :limit, :integer
#       arg :before, :string
#       arg :after, :string
#       resolve &CommonResolver.category_tags/3
#     end

#   end

#   object :tag_categories_edges do
#     field :page_info, non_null(:page_info)
#     field :edges, list_of(:tag_categories_edge)
#     field :total_count, non_null(:integer)
#   end

#   object :tag_categories_edge do
#     field :cursor, non_null(:string)
#     field :node, :tag_category
#   end


  # @desc "A category is a grouping mechanism for tags"
  # object :tag_category do
  #   @desc "An instance-local UUID identifying the category"
  #   field :id, :string
  #   @desc "A url for the category, may be to a remote instance"
  #   field :canonical_url, :string

  #   @desc "The name of the tag category"
  #   field :name, :string

  #   @desc "Whether the like is local to the instance"
  #   field :is_local, :boolean
  #   @desc "Whether the like is public"
  #   field :is_public, :boolean

  #   @desc "When the like was created"
    # field :created_at, :string do
    #   resolve &CommonResolver.created_at/3
    # end

  #   # @desc "The current user's follow of the category, if any"
  #   # field :my_follow, :follow do
  #   #   resolve &CommonResolver.my_follow/3
  #   # end

  #   @desc "The tags in the category, most recently created first"
  #   field :tags, :tags_edges do
  #     arg :limit, :integer
  #     arg :before, :string
  #     arg :after, :string
  #     resolve &CommonResolver.category_tags/3
  #   end

  # end

  # object :tag_categories_edges do
  #   field :page_info, non_null(:page_info)
  #   field :edges, list_of(:tag_categories_edge)
  #   field :total_count, non_null(:integer)
  # end

  # object :tag_categories_edge do
  #   field :cursor, non_null(:string)
  #   field :node, :tag_category
  # end

end
