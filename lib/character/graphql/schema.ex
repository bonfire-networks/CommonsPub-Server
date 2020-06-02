# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule Character.GraphQL.Schema do
  @moduledoc """
  GraphQL character fields, associations, queries and mutations.
  """
  use Absinthe.Schema.Notation
  alias MoodleNetWeb.GraphQL.{
    ActorsResolver,
    Character.GraphQL.Resolver,
    CommonResolver,
    FlagsResolver,
    FollowsResolver,
    LikesResolver,
    ThreadsResolver,
    UsersResolver,
    UploadResolver,
  }

  alias MoodleNet.{
    Communities.Community,
    Collections.Collection
  }

  alias Character.GraphQL.Resolver

  object :character_queries do

    @desc "Get a character by id"
    field :character, :character do
      arg :character_id, non_null(:string)
      resolve &Character.GraphQL.Resolver.character/2
    end

    @desc "Get list of characters, most recent activity first"
    field :characters, non_null(:characters_page) do
      arg :limit, :integer
      arg :before, list_of(non_null(:cursor))
      arg :after, list_of(non_null(:cursor))
      resolve &Character.GraphQL.Resolver.characters/2
    end

  end

  object :character_mutations do

    @desc "Create a character"
    field :create_character, :character do
      arg :characteristic_id, :string
      arg :context_id, :string
      arg :character, non_null(:character_input)
      resolve &Character.GraphQL.Resolver.create_character/2
    end

    @desc "Update a character"
    field :update_character, :character do
      arg :character_id, non_null(:string)
      arg :character, non_null(:character_update_input)
      resolve &Character.GraphQL.Resolver.update_character/2
    end

  end

  @desc """
  A character is the home of resources and discussion threads within a community
  """
  object :character do
    @desc "An instance-local UUID identifying the user"
    field :id, non_null(:string)

    @desc "The Thing that this Character represents"
    field :characteristic, :characteristic do
      resolve &CommonResolver.characteristic_edge/3
    end

    @desc "A friendly name for the type of thing this character represents, eg. Organisation, Location, Topic, Category..."
    field :facet, non_null(:string)

    @desc "A url for the character, may be to a remote instance"
    field :canonical_url, :string do
      resolve &ActorsResolver.canonical_url_edge/3
    end
    
    @desc "An instance-unique identifier shared with users and communities"
    field :preferred_username, non_null(:string) do
      resolve &ActorsResolver.preferred_username_edge/3
    end

    @desc "A preferred username + the host domain"
    field :display_username, non_null(:string) do
      resolve &ActorsResolver.display_username_edge/3
    end

    @desc "A name field"
    field :name, non_null(:string)

    @desc "Possibly biographical information"
    field :summary, :string

    @desc "An avatar url"
    field :icon, :content do
      resolve &UploadResolver.icon_content_edge/3
    end

    @desc "A JSON document containing more info beyond the default fields"
    field :extra_info, :json

    @desc "Whether the character is local to the instance"
    field :is_local, non_null(:boolean) do
      resolve &ActorsResolver.is_local_edge/3
    end
    @desc "Whether the character is public"
    field :is_public, non_null(:boolean) do
      resolve &CommonResolver.is_public_edge/3
    end
    @desc "Whether an instance admin has hidden the character"
    field :is_disabled, non_null(:boolean) do
      resolve &CommonResolver.is_disabled_edge/3
    end

    @desc "When the character was created"
    field :created_at, non_null(:string) do
      resolve &CommonResolver.created_at_edge/3
    end

    @desc "When the character was last updated"
    field :updated_at, non_null(:string)

    @desc """
    When the character or a resource in it was last updated or a
    thread or a comment was created or updated
    """
    field :last_activity, non_null(:string) do
      resolve &Character.GraphQL.Resolver.last_activity_edge/3
    end

    @desc "The current user's like of this character, if any"
    field :my_like, :like do
      resolve &LikesResolver.my_like_edge/3
    end

    @desc "The current user's follow of this character, if any"
    field :my_follow, :follow do
      resolve &FollowsResolver.my_follow_edge/3
    end

     @desc "The current user's flag of the character, if any"
    field :my_flag, :flag do
      resolve &FlagsResolver.my_flag_edge/3
    end

    # @desc "The primary language the community speaks"
    # field :primary_language, :language do
    #   resolve &LocalisationResolver.primary_language/3
    # end

    @desc "The user who created the character"
    field :creator, :user do
      resolve &UsersResolver.creator_edge/3
    end

    @desc "The parent of the character"
    field :context, :community do
      resolve &CommonResolver.context_edge/3
    end

    @desc "Total number of followers, including those we can't see"
    field :follower_count, :integer do
      resolve &FollowsResolver.follower_count_edge/3
    end

    @desc "Total number of likers, including those we can't see"
    field :liker_count, :integer do
      resolve &LikesResolver.liker_count_edge/3
    end

    @desc "Subscriptions users have to the character"
    field :followers, :follows_page do
      arg :limit, :integer
      arg :before, list_of(non_null(:cursor))
      arg :after, list_of(non_null(:cursor))
      resolve &FollowsResolver.followers_edge/3
    end

    @desc "Likes users have made of the character"
    field :likers, :likes_page do
      arg :limit, :integer
      arg :before, list_of(non_null(:cursor))
      arg :after, list_of(non_null(:cursor))
      resolve &LikesResolver.likers_edge/3
    end

    @desc "Flags users have made about the character, most recently created first"
    field :flags, :flags_page do
      arg :limit, :integer
      arg :before, list_of(non_null(:cursor))
      arg :after, list_of(non_null(:cursor))
      resolve &FlagsResolver.flags_edge/3
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
      arg :limit, :integer
      arg :before, list_of(non_null(:cursor))
      arg :after, list_of(non_null(:cursor))
      resolve &ThreadsResolver.threads_edge/3
    end

    @desc "Activities on the character, most recent first"
    field :outbox, :activities_page do
      arg :limit, :integer
      arg :before, list_of(non_null(:cursor))
      arg :after, list_of(non_null(:cursor))
      resolve &Character.GraphQL.Resolver.outbox_edge/3
    end

  end

  object :characters_page do
    field :page_info, non_null(:page_info)
    field :edges, non_null(list_of(non_null(:character)))
    field :total_count, non_null(:integer)
  end

  input_object :character_input do
    field :preferred_username, :string
    field :name, non_null(:string)
    field :summary, :string
    # field :primary_language_id, :string
  end

  input_object :character_update_input do
    field :name, non_null(:string)
    field :summary, :string
    # field :primary_language_id, :string
  end

  union :characteristic do
    description "The Thing that this character represents"
    types [:collection, :community, :organisation, :character]
    resolve_type fn
      %Collection{}, _ -> :collection
      %Community{},  _ -> :community
      %Organisation{},       _ -> :organisation
      %Character{},   _ -> :character
    end
  end

  union :character_context do
    description "The parent of this character"
    types [:collection, :community, :organisation, :character]
    resolve_type fn
      %Collection{}, _ -> :collection
      %Community{},  _ -> :community
      %Organisation{},       _ -> :organisation
      %Character{},   _ -> :character
    end
  end

end
