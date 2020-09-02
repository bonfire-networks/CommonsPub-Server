# SPDX-License-Identifier: AGPL-3.0-only
defmodule CommonsPub.Tag.GraphQL.TagSchema do
  use Absinthe.Schema.Notation
  alias MoodleNetWeb.GraphQL.{UsersResolver}
  alias CommonsPub.Tag.GraphQL.{TagResolver}

  object :tag_queries do
    @desc "Get list of categories we know about"
    field :categories, non_null(:categories_page) do
      arg(:limit, :integer)
      arg(:before, list_of(non_null(:cursor)))
      arg(:after, list_of(non_null(:cursor)))
      resolve(&TagResolver.categories/2)
    end

    @desc "Get a category by ID "
    field :category, :category do
      arg(:category_id, :string)
      # arg :find, :category_find
      resolve(&TagResolver.category/2)
    end

    @desc "Get a taggable by ID "
    field :taggable, :taggable do
      arg(:id, :string)
      # arg :find, :category_find
      resolve(&TagResolver.taggable/2)
    end
  end

  object :tag_mutations do
    @desc "Create a new Category"
    field :create_category, :category do
      arg(:category, :category_input)

      arg(:profile, :profile_input)
      arg(:character, :character_input)

      resolve(&TagResolver.create_category/2)
    end

    @desc "Create a Taggable out of something else. You can also directly use the tag() mutation with a pointer ID instead."
    field :make_taggable, :taggable do
      arg(:context_id, :string)
      resolve(&TagResolver.make_pointer_taggable/2)
    end

    @desc "Tag a thing (using a Pointer) with one or more Taggables (or Categories, or even Pointers to anything that can become taggable)"
    field :tag, :boolean do
      arg(:thing, non_null(:string))
      arg(:taggables, non_null(list_of(:string)))
      resolve(&TagResolver.thing_attach_tags/2)
    end

    @desc "Update a category"
    field :update_category, :category do
      arg(:category_id, :id)

      arg(:category, :category_input)

      arg(:profile, :profile_input)
      arg(:character, :character_input)

      resolve(&TagResolver.update_category/2)
    end
  end

  @desc "A category (eg. tag in a taxonomy)"
  object :category do
    @desc "The numeric primary key of the category"
    field(:id, :string)

    field(:prefix, :string)
    field(:facet, :string)

    # field(:name, :string)
    field(:name, :string) do
      resolve(&TagResolver.name/3)
    end

    # field(:summary, :string)
    field(:summary, :string) do
      resolve(&TagResolver.summary/3)
    end

    field(:parent_category_id, :string)

    @desc "The parent category (in a tree-based taxonomy)"
    field :parent_category, :category do
      resolve(&TagResolver.parent_category/3)
    end

    @desc "List of child categories (in a tree-based taxonomy)"
    field :sub_categories, list_of(:categories_page) do
      resolve(&TagResolver.category_children/3)
    end

    @desc "The caretaker of this category, if any"
    field :caretaker, :any_context do
      # resolve(&MoodleNetWeb.GraphQL.CommonResolver.context_edge/3)
    end

    @desc "The character that represents this category in feeds and federation"
    field :character, :character do
      resolve(&CommonsPub.Character.GraphQL.Resolver.character/3)
    end

    @desc "The profile that represents this category"
    field :profile, :profile do
      resolve(&CommonsPub.Profile.GraphQL.Resolver.profile/3)
    end

    @desc "The user who created the character"
    field :creator, :user do
      resolve(&UsersResolver.creator_edge/3)
    end
  end

  @desc "A taggable could be a category or hashtag or user or community or etc"
  object :taggable do
    @desc "The numeric primary key of the taggable"
    field(:id, :string)

    field(:prefix, :string)
    field(:facet, :string)

    # field(:name, :string)
    field(:name, :string) do
      resolve(&TagResolver.name/3)
    end

    # field(:summary, :string)
    field(:summary, :string) do
      resolve(&TagResolver.summary/3)
    end

    @desc "The taggable object, like a category or community"
    field :context, :any_context do
      resolve(&MoodleNetWeb.GraphQL.CommonResolver.context_edge/3)
    end

    @desc "Things that were tagged with this tag"
    field(:things, list_of(:any_context)) do
      resolve(&TagResolver.tagged_things_edges/3)
    end
  end

  object :categories_page do
    field(:page_info, non_null(:page_info))
    field(:edges, non_null(list_of(non_null(:category))))
    field(:total_count, non_null(:integer))
  end

  input_object :category_find do
    field(:name, non_null(:string))
    field(:parent_category_name, non_null(:string))
  end

  input_object :category_input do
    field(:prefix, :string)
    field(:facet, :string)

    field(:parent_category, :id)
    field(:same_as_category, :id)
  end

  #  @desc "A category is a grouping mechanism for categories"
  #   object :category_category do
  #     @desc "An instance-local UUID identifying the category"
  #     field :id, :string
  #     @desc "A url for the category, may be to a remote instance"
  #     field :canonical_url, :string

  #     @desc "The name of the category category"
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

  #     @desc "The categories in the category, most recently created first"
  #     field :categories, :categories_edges do
  #       arg :limit, :integer
  #       arg :before, :string
  #       arg :after, :string
  #       resolve &CommonResolver.category_categories/3
  #     end

  #   end

  # @desc "A category is a grouping mechanism for categories"
  # object :category_category do
  #   @desc "An instance-local UUID identifying the category"
  #   field :id, :string
  #   @desc "A url for the category, may be to a remote instance"
  #   field :canonical_url, :string

  #   @desc "The name of the category category"
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

  #   @desc "The categories in the category, most recently created first"
  #   field :categories, :categories_edges do
  #     arg :limit, :integer
  #     arg :before, :string
  #     arg :after, :string
  #     resolve &CommonResolver.category_categories/3
  #   end

  # end
end
