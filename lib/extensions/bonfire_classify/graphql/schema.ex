# SPDX-License-Identifier: AGPL-3.0-only
defmodule Bonfire.Classify.GraphQL.ClassifySchema do
  use Absinthe.Schema.Notation

  alias CommonsPub.Web.GraphQL.UsersResolver
  alias Bonfire.Classify.GraphQL.CategoryResolver

  object :classify_queries do

    @desc "Get list of categories we know about"
    field :categories, non_null(:categories_page) do
      arg(:limit, :integer)
      arg(:before, list_of(non_null(:cursor)))
      arg(:after, list_of(non_null(:cursor)))
      resolve(&CategoryResolver.categories/2)
    end

    @desc "Get a category by ID "
    field :category, :category do
      arg(:category_id, :string)
      # arg :find, :category_find
      resolve(&CategoryResolver.category/2)
    end

  end

  object :classify_mutations do
    @desc "Create a new Category"
    field :create_category, :category do
      arg(:category, :category_input)

      arg(:profile, :profile_input)
      arg(:character, :character_input)

      resolve(&CategoryResolver.create_category/2)
    end


    @desc "Update a category"
    field :update_category, :category do
      arg(:category_id, :id)

      arg(:category, :category_input)

      arg(:profile, :profile_input)
      arg(:character, :character_input)

      resolve(&CategoryResolver.update_category/2)
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
      resolve(&CategoryResolver.name/3)
    end

    # field(:summary, :string)
    field(:summary, :string) do
      resolve(&CategoryResolver.summary/3)
    end

    field(:parent_category_id, :string)

    @desc "The parent category (in a tree-based taxonomy)"
    field :parent_category, :category do
      resolve(&CategoryResolver.parent_category/3)
    end

    @desc "List of child categories (in a tree-based taxonomy)"
    field :sub_categories, list_of(:categories_page) do
      resolve(&CategoryResolver.category_children/3)
    end

    @desc "The caretaker of this category, if any"
    field :caretaker, :any_context do
      # resolve(&Bonfire.GraphQL.CommonResolver.context_edge/3)
    end

    @desc "The character that represents this category in feeds and federation"
    field :character, :character do
      resolve(&CommonsPub.Characters.GraphQL.Resolver.character/3)
    end

    @desc "The profile that represents this category"
    field :profile, :profile do
      resolve(&CommonsPub.Profiles.GraphQL.Resolver.profile/3)
    end

    @desc "The user who created the character"
    field :creator, :user do
      resolve(&UsersResolver.creator_edge/3)
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
