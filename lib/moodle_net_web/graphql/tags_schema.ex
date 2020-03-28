# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.TagsSchema do

  use Absinthe.Schema.Notation
  # alias MoodleNet.Collections.Collection
  # alias MoodleNet.Communities.Community
  # alias MoodleNetWeb.GraphQL.{CommonResolver, TagsResolver}

  object :tags_queries do
    # field :tag, :tag do
    #   arg :tag_id, non_null(:string)
    #   resolve &TagsResolver.tag/2
    # end
    # field :tag_category, :tag_category do
    #   arg :tag_category_id, non_null(:string)
    #   resolve &TagsResolver.tag_category/2
    # end
    # field :tagging, :tagging do
    #   arg :tagging_id, non_null(:string)
    #   resolve &TagsResolver.tagging/2
    # end
  end

  object :tags_mutations do

    # @desc "Tag something, returning a tagging id"
    # field :create_tagging, :tagging do
    #   arg :context_id, non_null(:string)
    #   arg :tag_id, non_null(:string)
    #   resolve &TagsResolver.create_tagging/2
    # end

  end

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
  #   field :created_at, :string do
  #     resolve &CommonResolver.created_at/3
  #   end

  #   # @desc "The current user's follow of the category, if any"
  #   # field :my_follow, :follow do
  #   #   resolve &CommonResolver.my_follow/3
  #   # end

  #   @desc "The tags in the category, most recently created first"
  #   field :tags, :tags_edges do
  #     arg :limit, :integer
  #     arg :before, list_of(:cursor)
  #     arg :after, list_of(:cursor)
  #     resolve &CommonResolver.category_tags/3
  #   end

  # end

  # object :tag_categories_edges do
  #   field :page_info, non_null(:page_info)
  #   field :edges, list_of(:tag_categories_edge)
  #   field :total_count, non_null(:integer)
  # end

  # object :tag_categories_edge do
  #   field list_of(:cursor), non_null(:string)
  #   field :node, :tag_category
  # end


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
  #     arg :before, list_of(:cursor)
  #     arg :after, list_of(:cursor)
  #     resolve &CommonResolver.category_tags/3
  #   end

  # end

  # object :tag_categories_edges do
  #   field :page_info, non_null(:page_info)
  #   field :edges, list_of(:tag_category)
  #   field :total_count, non_null(:integer)
  # end

end
