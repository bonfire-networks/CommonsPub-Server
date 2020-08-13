# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule Profile.GraphQL.Schema do
  @moduledoc """
  GraphQL profile fields, associations, queries and mutations.
  """
  use Absinthe.Schema.Notation

  alias MoodleNetWeb.GraphQL.{
    # Profile.GraphQL.Resolver,
    CommonResolver,
    FlagsResolver,
    # FollowsResolver,
    LikesResolver,
    # ThreadsResolver,
    UsersResolver,
    UploadResolver
    # CommunitiesResolver,
    # CollectionsResolver
  }

  object :profile_queries do
    @desc "Get a profile by id. You usually would query for a type associated with profile, rather than profiles directly."
    field :profile, :profile do
      arg(:profile_id, non_null(:string))
      resolve(&Profile.GraphQL.Resolver.profile/2)
    end

    @desc "Get list of profiles. You usually would query for a type associated with profile, rather than profiles directly."
    field :profiles, non_null(:profiles_page) do
      arg(:limit, :integer)
      arg(:before, list_of(non_null(:cursor)))
      arg(:after, list_of(non_null(:cursor)))
      arg(:facets, list_of(non_null(:string)))
      resolve(&Profile.GraphQL.Resolver.profiles/2)
    end
  end

  object :profile_mutations do
    # @desc "Create a profile. You usually wouldn't do this directly."
    # field :create_profile, :profile do
    #   arg :profileistic_id, :string
    #   arg :context_id, :string
    #   arg :profile, non_null(:profile_input)
    #   resolve &Profile.GraphQL.Resolver.create_profile/2
    # end

    # @desc "Update a profile. You usually wouldn't do this directly."
    # field :update_profile, :profile do
    #   arg :profile_id, non_null(:string)
    #   arg :profile, non_null(:profile_update_input)
    #   resolve &Profile.GraphQL.Resolver.update_profile/2
    # end

    @desc "Create a Profile to represent something (which already exists, pass the ID passed as context) in feeds and federation"
    field :add_profile_to, :profile do
      arg(:context_id, non_null(:string))
      resolve(&Profile.GraphQL.Resolver.add_profile_to/2)
    end
  end

  @desc """
  A profile is anything (Person, Group, Organisation, Taxonomy Tag, Location, Thread, what-have-you...) which has a feed which can be followed, and can be tagged in other activities
  """
  object :profile do
    @desc "An instance-local UUID identifying the profile. Not to be confused with the associated thing's ID (available under profileistic.id)"
    field(:id, non_null(:string))

    # @desc "A reference to the thing that this Profile represents"
    # field :profileistic_id, :string
    # field :profileistic, :profile_tropes do
    #   resolve &Profile.GraphQL.Resolver.profileistic_edge/3
    # end

    @desc "A url for the profile, may be to a remote instance"
    field :canonical_url, :string do
      resolve(&CommonsPub.Character.GraphQL.Resolver.canonical_url_edge/3)
    end

    @desc "An instance-unique identifier shared with users and communities"
    field :preferred_username, non_null(:string) do
      resolve(&CommonsPub.Character.GraphQL.Resolver.preferred_username_edge/3)
    end

    @desc "A preferred username + the host domain"
    field :display_username, non_null(:string) do
      resolve(&CommonsPub.Character.GraphQL.Resolver.display_username_edge/3)
    end

    @desc "A name field"
    field(:name, non_null(:string))

    @desc "Possibly biographical information"
    field(:summary, :string)

    @desc "An avatar or icon url"
    field :icon, :content do
      resolve(&UploadResolver.icon_content_edge/3)
    end

    @desc "A background image url"
    field :image, :content do
      resolve(&UploadResolver.image_content_edge/3)
    end

    @desc "A JSON document containing more info beyond the default fields"
    field(:extra_info, :json)

    @desc "Whether the profile is local to the instance"
    field :is_local, non_null(:boolean) do
      resolve(&CommonsPub.Character.GraphQL.Resolver.is_local_edge/3)
    end

    @desc "Whether the profile is public"
    field :is_public, non_null(:boolean) do
      resolve(&CommonResolver.is_public_edge/3)
    end

    @desc "Whether an instance admin has hidden the profile"
    field :is_disabled, non_null(:boolean) do
      resolve(&CommonResolver.is_disabled_edge/3)
    end

    @desc "When the profile was created"
    field :created_at, non_null(:string) do
      resolve(&CommonResolver.created_at_edge/3)
    end

    @desc "When the profile was last updated"
    field(:updated_at, non_null(:string))

    @desc "The current user's like of this profile, if any"
    field :my_like, :like do
      resolve(&LikesResolver.my_like_edge/3)
    end

    @desc "The current user's flag of the profile, if any"
    field :my_flag, :flag do
      resolve(&FlagsResolver.my_flag_edge/3)
    end

    # @desc "The primary language the profile speaks"
    # field :primary_language, :language do
    #   resolve &LocalisationResolver.primary_language/3
    # end

    @desc "The user who created the profile"
    field :creator, :user do
      resolve(&UsersResolver.creator_edge/3)
    end

    @desc "Total number of likers, including those we can't see"
    field :liker_count, :integer do
      resolve(&LikesResolver.liker_count_edge/3)
    end

    @desc "Likes users have made of the profile"
    field :likers, :likes_page do
      arg(:limit, :integer)
      arg(:before, list_of(non_null(:cursor)))
      arg(:after, list_of(non_null(:cursor)))
      resolve(&LikesResolver.likers_edge/3)
    end

    @desc "Flags users have made about the profile, most recently created first"
    field :flags, :flags_page do
      arg(:limit, :integer)
      arg(:before, list_of(non_null(:cursor)))
      arg(:after, list_of(non_null(:cursor)))
      resolve(&FlagsResolver.flags_edge/3)
    end

    # @desc "Tags users have applied to the resource, most recently created first"
    # field :taggings, :taggings_page do
    #   arg :limit, :integer
    #   arg :before, list_of(non_null(:cursor))
    #   arg :after, list_of(non_null(:cursor))
    #   resolve &CommonResolver.taggings_edge/3
    # end
  end

  object :profiles_page do
    field(:page_info, non_null(:page_info))
    field(:edges, non_null(list_of(non_null(:profile))))
    field(:total_count, non_null(:integer))
  end

  input_object :profile_input do
    # field(:preferred_username, :string)
    field(:name, non_null(:string))
    field(:summary, :string)
    # field :primary_language_id, :string
  end

  input_object :profile_update_input do
    field(:name, non_null(:string))
    field(:summary, :string)
    # field :primary_language_id, :string
  end
end
