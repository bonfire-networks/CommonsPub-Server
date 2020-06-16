# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule Taxonomy.GraphQL.TagsSchema do

  use Absinthe.Schema.Notation
  alias MoodleNetWeb.GraphQL.{CommonResolver}
  alias Taxonomy.GraphQL.{TagsResolver}

  object :taxonomy_queries do

    @desc "Get list of tags we know about"
    field :tags, non_null(:tags_page) do
      arg :limit, :integer
      arg :before, list_of(non_null(:cursor))
      arg :after, list_of(non_null(:cursor))
      resolve &TagsResolver.tags/2
    end

    @desc "Get a tag by ID "
    field :tag, :tag do
      arg :tag_id, :integer
      arg :pointer_id, :string
      # arg :find, :tag_find
      resolve &TagsResolver.tag/2
    end

  end

  object :taxonomy_mutations do

    @desc "Create a Character to represents this tag in feeds and federation"
    field :characterise_tag, :character do
      arg :tag_id, :integer
      resolve &TagsResolver.characterise_tag/2
    end

  end

  object :tag do

    @doc "The numeric primary key of the tag"
    field(:id, :integer)

    @doc "The ULID/pointer ID of the tag. Only exists once the tag is used in the app."
    field(:pointer_id, :string)

    field(:label, :string)
    field(:description, :string)

    # field(:parent_tag_id, :integer)

    @desc "The parent tag (in a tree-based taxonomy)"
    field :parent_tag, :tag do
      resolve &TagsResolver.parent_tag/3
    end

    @desc "List of child tag (in a tree-based taxonomy)"
    field :tags, list_of(:tags_page) do
      resolve &TagsResolver.tag_children/3
    end

    field(:character_id, :string)
    @desc "The Character that represents this tag in feeds and federation"
    field :character, :character do
      resolve &Character.GraphQL.Resolver.character/3
    end

  end

  object :tags_page do
    field :page_info, non_null(:page_info)
    field :edges, non_null(list_of(non_null(:tag)))
    field :total_count, non_null(:integer)
  end

  input_object :tag_find do
    field :label, non_null(:string)
    field :parent_tag_label, non_null(:string)
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



end