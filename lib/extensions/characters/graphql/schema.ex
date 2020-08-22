# SPDX-License-Identifier: AGPL-3.0-only
defmodule CommonsPub.Character.GraphQL.Schema do
  @moduledoc """
  GraphQL character fields, associations, queries and mutations.
  """
  use Absinthe.Schema.Notation

  alias MoodleNetWeb.GraphQL.{
    ActorsResolver,
    CommonResolver,
    FlagsResolver,
    FollowsResolver,
    LikesResolver,
    ThreadsResolver,
    UsersResolver,
    # UploadResolver,
    CommunitiesResolver,
    CollectionsResolver
  }

  alias MoodleNet.{
    Communities.Community,
    Collections.Collection,
    Resources.Resource,
    Threads.Thread,
    Threads.Comment
  }

  # alias CommonsPub.Character.GraphQL.Resolver

  object :character_queries do
    @desc "Get a character by id. You usually would query for a type associated with character, rather than characters directly."
    field :character, :character do
      arg(:character_id, non_null(:string))
      resolve(&CommonsPub.Character.GraphQL.Resolver.character/2)
    end

    @desc "Get list of characters. You usually would query for a type associated with character, rather than characters directly."
    field :characters, non_null(:characters_page) do
      arg(:limit, :integer)
      arg(:before, list_of(non_null(:cursor)))
      arg(:after, list_of(non_null(:cursor)))
      arg(:facets, list_of(non_null(:string)))
      resolve(&CommonsPub.Character.GraphQL.Resolver.characters/2)
    end
  end

  object :character_mutations do
    # @desc "Create a character. You usually wouldn't do this directly."
    # field :create_character, :character do
    #   arg :characteristic_id, :string
    #   arg :context_id, :string
    #   arg :character, non_null(:character_input)
    #   resolve &CommonsPub.Character.GraphQL.Resolver.create_character/2
    # end

    # @desc "Update a character. You usually wouldn't do this directly."
    # field :update_character, :character do
    #   arg :character_id, non_null(:string)
    #   arg :character, non_null(:character_update_input)
    #   resolve &CommonsPub.Character.GraphQL.Resolver.update_character/2
    # end

    @desc "Create a character to represent something (which already exists, pass the ID passed as context) in feeds and federation"
    field :characterise, :character do
      arg(:context_id, non_null(:string))
      resolve(&CommonsPub.Character.GraphQL.Resolver.characterise/2)
    end
  end

  @desc """
  A character is anything (Person, Group, Organisation, Taxonomy Tag, Location, Thread, what-have-you...) which has a feed which can be followed, and can be tagged in other activities
  """
  object :character do
    @desc "An instance-local UUID identifying the character. Not to be confused with the associated thing's ID (available under characteristic.id)"
    field(:id, non_null(:string))

    # @desc "A reference to the thing that this character represents"
    # field :characteristic_id, :string
    # field :characteristic, :character_tropes do
    #   resolve &CommonsPub.Character.GraphQL.Resolver.characteristic_edge/3
    # end

    @desc "A friendly name for the type of thing this character represents, eg. Organisation, Location, Tag..."
    field(:facet, non_null(:string))

    @desc "A url for the character, may be to a remote instance"
    field :canonical_url, :string do
      resolve(&ActorsResolver.canonical_url_edge/3)
    end

    @desc "An instance-unique identifier shared with users and communities"
    field :preferred_username, non_null(:string) do
      resolve(&ActorsResolver.preferred_username_edge/3)
    end

    @desc "A preferred username + the host domain"
    field :display_username, non_null(:string) do
      resolve(&ActorsResolver.display_username_edge/3)
    end

    # @desc "A name field"
    # field :name, non_null(:string)

    # @desc "Possibly biographical information"
    # field :summary, :string

    # @desc "An avatar or icon url"
    # field :icon, :content do
    #   resolve &UploadResolver.icon_content_edge/3
    # end

    # @desc "A background image url"
    # field :image, :content do
    #   resolve &UploadResolver.image_content_edge/3
    # end

    # @desc "A JSON document containing more info beyond the default fields"
    # field :extra_info, :json

    @desc "Whether the character is local to the instance"
    field :is_local, non_null(:boolean) do
      resolve(&ActorsResolver.is_local_edge/3)
    end

    @desc "Whether the character is public"
    field :is_public, non_null(:boolean) do
      resolve(&CommonResolver.is_public_edge/3)
    end

    @desc "Whether an instance admin has hidden the character"
    field :is_disabled, non_null(:boolean) do
      resolve(&CommonResolver.is_disabled_edge/3)
    end

    @desc "When the character was created"
    field :created_at, non_null(:string) do
      resolve(&CommonResolver.created_at_edge/3)
    end

    @desc "When the character was last updated"
    field(:updated_at, non_null(:string))

    @desc """
    When the character or a resource in it was last updated or a
    thread or a comment was created or updated
    """
    field :last_activity, non_null(:string) do
      resolve(&CommonsPub.Character.GraphQL.Resolver.last_activity_edge/3)
    end

    @desc "The current user's like of this character, if any"
    field :my_like, :like do
      resolve(&LikesResolver.my_like_edge/3)
    end

    @desc "The current user's follow of this character, if any"
    field :my_follow, :follow do
      resolve(&FollowsResolver.my_follow_edge/3)
    end

    @desc "The current user's flag of the character, if any"
    field :my_flag, :flag do
      resolve(&FlagsResolver.my_flag_edge/3)
    end

    # @desc "The primary language the character speaks"
    # field :primary_language, :language do
    #   resolve &LocalisationResolver.primary_language/3
    # end

    @desc "The user who created the character"
    field :creator, :user do
      resolve(&UsersResolver.creator_edge/3)
    end

    @desc "The parent of the character"
    field :context, :any_context do
      resolve(&CommonResolver.context_edge/3)
    end

    @desc "Any communities linked under this character"
    field :communities, :communities_page do
      arg(:limit, :integer)
      arg(:before, list_of(non_null(:cursor)))
      arg(:after, list_of(non_null(:cursor)))
      resolve(&CommunitiesResolver.communities_edge/3)
    end

    # @desc "The total number of collections in the character, including private ones"
    # field :collection_count, :integer do
    #   resolve &CommunitiesResolver.collection_count_edge/3
    # end

    @desc "Any organisations created under this character"
    field :organisations, :organisations_page do
      arg(:limit, :integer)
      arg(:before, list_of(non_null(:cursor)))
      arg(:after, list_of(non_null(:cursor)))
      resolve(&Organisation.GraphQL.Resolver.organisations_edge/3)
    end

    @desc "Any collections created under this character"
    field :collections, :collections_page do
      arg(:limit, :integer)
      arg(:before, list_of(non_null(:cursor)))
      arg(:after, list_of(non_null(:cursor)))
      resolve(&CollectionsResolver.collections_edge/3)
    end

    # @desc "The total number of resources in the collection, including private ones"
    # field :resource_count, :integer do
    #   resolve &CollectionsResolver.resource_count_edge/3
    # end

    @desc "Any resources posted under this character, most recent last"
    field :resources, :resources_page do
      arg(:limit, :integer)
      arg(:before, list_of(non_null(:cursor)))
      arg(:after, list_of(non_null(:cursor)))
      resolve(&ResourcesResolver.resources_edge/3)
    end

    # @desc "Any tags linked under this character"
    # field :tags, :tags_page do
    #   arg(:limit, :integer)
    #   arg(:before, list_of(non_null(:cursor)))
    #   arg(:after, list_of(non_null(:cursor)))
    #   resolve(&Taxonomy.GraphQL.TaxonomyResolver.character_tags_edge/3)
    # end

    @desc "Total number of followers, including those we can't see"
    field :follower_count, :integer do
      resolve(&FollowsResolver.follower_count_edge/3)
    end

    @desc "Subscriptions users have to the character"
    field :followers, :follows_page do
      arg(:limit, :integer)
      arg(:before, list_of(non_null(:cursor)))
      arg(:after, list_of(non_null(:cursor)))
      resolve(&FollowsResolver.followers_edge/3)
    end

    # @desc "Tags users have applied to the resource, most recently created first"
    # field :taggings, :taggings_page do
    #   arg :limit, :integer
    #   arg :before, list_of(non_null(:cursor))
    #   arg :after, list_of(non_null(:cursor))
    #   resolve &CommonResolver.taggings_edge/3
    # end

    @desc """
    The threads created on the character, most recently created
    first. Does not include threads created on resources.
    """
    field :threads, :threads_page do
      arg(:limit, :integer)
      arg(:before, list_of(non_null(:cursor)))
      arg(:after, list_of(non_null(:cursor)))
      resolve(&ThreadsResolver.threads_edge/3)
    end

    @desc "Activities on the character, most recent first"
    field :outbox, :activities_page do
      arg(:limit, :integer)
      arg(:before, list_of(non_null(:cursor)))
      arg(:after, list_of(non_null(:cursor)))
      resolve(&CommonsPub.Character.GraphQL.Resolver.outbox_edge/3)
    end
  end

  object :characters_page do
    field(:page_info, non_null(:page_info))
    field(:edges, non_null(list_of(non_null(:character))))
    field(:total_count, non_null(:integer))
  end

  input_object :character_input do
    field(:preferred_username, :string)
    # field(:name, non_null(:string))
    # field(:summary, :string)
    # field :primary_language_id, :string
  end

  input_object :character_update_input do
    field(:name, non_null(:string))
    field(:summary, :string)
    # field :primary_language_id, :string
  end
end
