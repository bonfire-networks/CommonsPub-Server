# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule Tag.GraphQL.TagSchema do
  use Absinthe.Schema.Notation
  # alias MoodleNetWeb.GraphQL.{CommonResolver}
  alias Tag.GraphQL.{TagResolver}

  object :tag_queries do
    @desc "Get list of tags we know about"
    field :tags, non_null(:tags_page) do
      arg(:limit, :integer)
      arg(:before, list_of(non_null(:cursor)))
      arg(:after, list_of(non_null(:cursor)))
      resolve(&TagResolver.tags/2)
    end

    @desc "Get a tag by ID "
    field :tag, :tag do
      arg(:tag_id, :string)
      arg(:taxonomy_tag_id, :integer)
      # arg :find, :tag_find
      resolve(&TagResolver.tag/2)
    end
  end

  object :tag_mutations do
    @desc "Create a tag out of something else. You can also directly use tag() with a pointer ID instead."
    field :make_taggable, :tag do
      arg(:context_id, :string)
      resolve(&TagResolver.make_pointer_taggable/2)
    end

    @desc "Tag something with a tag (or a taggable pointer)"
    field :tag, :tag do
      arg(:thing_id, non_null(:string))
      arg(:taggable_id, non_null(:string))
      resolve(&TagResolver.tag_thing/2)
    end
  end

  @desc "A tag could be a category or hashtag"
  object :tag do
    @desc "The numeric primary key of the tag"
    field(:id, :string)

    @desc "The ID of the corresponding TaxonomyTag, if any."
    field(:taxonomy_tag_id, :integer)

    field(:prefix, :string)

    # field(:name, :string)
    field(:name, :string) do
      resolve(&TagResolver.name/3)
    end

    # field(:summary, :string)
    field(:summary, :string) do
      resolve(&TagResolver.summary/3)
    end

    field(:parent_tag_id, :string)

    @desc "The parent tag (in a tree-based taxonomy)"
    field :parent_tag, :tag do
      resolve(&TagResolver.parent_tag/3)
    end

    @desc "List of child tag (in a tree-based taxonomy)"
    field :tags, list_of(:tags_page) do
      resolve(&TagResolver.tag_children/3)
    end

    @desc "The taggable object, or the context of this taggable"
    field :context, :any_context do
      resolve(&MoodleNetWeb.GraphQL.CommonResolver.context_edge/3)
    end

    @desc "The Character that represents this tag in feeds and federation"
    field :character, :character do
      resolve(&Character.GraphQL.Resolver.character/3)
    end

    @desc "The Profile that represents this tag"
    field :profile, :profile do
      resolve(&Profile.GraphQL.Resolver.profile/3)
    end

    @desc "Things that were tagged with this tag"
    field(:tagged_things, list_of(:any_context)) do
      resolve(&TagResolver.tagged_things_edges/3)
    end
  end

  object :tags_page do
    field(:page_info, non_null(:page_info))
    field(:edges, non_null(list_of(non_null(:tag))))
    field(:total_count, non_null(:integer))
  end

  input_object :tag_find do
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
