# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule Taxonomy.GraphQL.TaxonomySchema do
  use Absinthe.Schema.Notation
  # alias MoodleNetWeb.GraphQL.{CommonResolver}
  alias Taxonomy.GraphQL.{TaxonomyResolver}

  object :taxonomy_queries do
    @desc "Get list of taxonomy_tags we know about"
    field :taxonomy_tags, non_null(:taxonomy_tags_page) do
      arg(:limit, :integer)
      arg(:before, list_of(non_null(:cursor)))
      arg(:after, list_of(non_null(:cursor)))
      resolve(&TaxonomyResolver.tags/2)
    end

    @desc "Get a taxonomy_tag by ID "
    field :taxonomy_tag, :taxonomy_tag do
      arg(:tag_id, :integer)
      arg(:pointer_id, :string)
      # arg :find, :tag_find
      resolve(&TaxonomyResolver.tag/2)
    end
  end

  object :taxonomy_mutations do
    @desc "Create a Category to represents this taxonomy_tag in feeds and federation"
    field :ingest_taxonomy_tag, :taggable do
      arg(:taxonomy_tag_id, :integer)
      resolve(&TaxonomyResolver.ingest_taxonomy_tag/2)
    end
  end

  object :taxonomy_tag do
    @desc "The numeric primary key of the taxonomy_tag"
    field(:id, :integer)

    @desc "The ULID/pointer ID of the taxonomy_tag. Only exists once the tag is used in the app."
    field(:pointer_id, :string)

    field(:name, :string)
    field(:summary, :string)

    # field(:parent_tag_id, :integer)

    @desc "The parent taxonomy_tag (in a tree-based taxonomy)"
    field :parent_tag, :taxonomy_tag do
      resolve(&TaxonomyResolver.parent_tag/3)
    end

    @desc "List of child taxonomy_tag (in a tree-based taxonomy)"
    field :children_taxonomy_tags, list_of(:taxonomy_tags_page) do
      resolve(&TaxonomyResolver.tag_children/3)
    end

    @desc "The taggable Category that we can use in items, feeds and federation"
    field(:category, :category)
  end

  object :taxonomy_tags_page do
    field(:page_info, non_null(:page_info))
    field(:edges, non_null(list_of(non_null(:taxonomy_tag))))
    field(:total_count, non_null(:integer))
  end

  input_object :taxonomy_tag_find do
    field(:name, non_null(:string))
    field(:parent_tag_name, non_null(:string))
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
