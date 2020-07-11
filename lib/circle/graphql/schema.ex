# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule Circle.GraphQL.Schema do
  @moduledoc """
  GraphQL circle fields, associations, queries and mutations.
  """
  use Absinthe.Schema.Notation

  alias MoodleNetWeb.GraphQL.{
    ActorsResolver,
    # CommonResolver,
    # FlagsResolver,
    # FollowsResolver,
    # LikesResolver,
    ThreadsResolver
    # UsersResolver,
    # UploadResolver
  }

  alias Character.GraphQL.FacetsResolvers

  # alias Circle.GraphQL.Resolver

  object :circles_queries do
    @desc "Get a circle by id"
    field :circle, :circle do
      arg(:circle_id, non_null(:string))
      resolve(&Circle.GraphQL.Resolver.circle/2)
    end

    @desc "Get list of circles, most recent activity first"
    field :circles, non_null(:circles_page) do
      arg(:limit, :integer)
      arg(:before, list_of(non_null(:cursor)))
      arg(:after, list_of(non_null(:cursor)))
      resolve(&Circle.GraphQL.Resolver.circles/2)
    end
  end

  object :circles_mutations do
    @desc "Create a circle"
    field :create_circle, :circle do
      arg(:context_id, :string)
      arg(:circle, non_null(:circle_input))
      resolve(&Circle.GraphQL.Resolver.create_circle/2)
    end

    @desc "Update a circle"
    field :update_circle, :circle do
      arg(:circle_id, non_null(:string))
      arg(:circle, non_null(:circle_update_input))
      resolve(&Circle.GraphQL.Resolver.update_circle/2)
    end
  end

  @desc """
  An circle is an agent/actor that fronts several people/users
  """
  object :circle do
    @desc "An instance-local UUID identifying the user"
    field(:id, non_null(:string))

    @desc "A JSON document containing more info beyond the default fields"
    field(:extra_info, :json)

    @desc "A name field"
    field(:name, non_null(:string))

    @desc "Possibly biographical information"
    field(:summary, :string)

    @desc "When the circle was last updated"
    field(:updated_at, non_null(:string))

    @desc "A url for the circle, may be to a remote instance"
    field(:canonical_url, :string)

    @desc "An instance-unique identifier shared with users and communities"
    field(:preferred_username, :string)

    @desc "The Profile associated with this circle"
    field(:profile, :profile)

    @desc "The Character associated with this circle"
    field(:character, :character)

    @desc "A preferred username + the host domain"
    field :display_username, :string do
      # FIXME
      resolve(&ActorsResolver.display_username_edge/3)
    end

    @desc "An avatar url"
    field :icon, :content do
      resolve(&FacetsResolvers.icon_content_edge/3)
    end

    @desc "Another image url"
    field :image, :content do
      resolve(&FacetsResolvers.image_content_edge/3)
    end

    @desc "Whether the circle is local to the instance"
    field :is_local, non_null(:boolean) do
      resolve(&ActorsResolver.is_local_edge/3)
    end

    @desc "Whether the circle is public"
    field :is_public, non_null(:boolean) do
      resolve(&FacetsResolvers.is_public_edge/3)
    end

    @desc "Whether an instance admin has hidden the circle"
    field :is_disabled, non_null(:boolean) do
      resolve(&FacetsResolvers.is_disabled_edge/3)
    end

    # @desc "When the circle was created"
    # field :created_at, non_null(:string) do
    #   resolve &FacetsResolvers.created_at_edge/3
    # end

    @desc "The current user's like of this circle, if any"
    field :my_like, :like do
      resolve(&FacetsResolvers.my_like_edge/3)
    end

    @desc "The current user's follow of this circle, if any"
    field :my_follow, :follow do
      resolve(&FacetsResolvers.my_follow_edge/3)
    end

    @desc "The current user's flag of the circle, if any"
    field :my_flag, :flag do
      resolve(&FacetsResolvers.my_flag_edge/3)
    end

    # @desc "The primary language the community speaks"
    # field :primary_language, :language do
    #   resolve &LocalisationResolver.primary_language/3
    # end

    @desc "The user who created the circle"
    field :creator, :user do
      resolve(&FacetsResolvers.creator_edge/3)
    end

    @desc "The community the circle belongs to"
    field :context, :community do
      resolve(&FacetsResolvers.context_edge/3)
    end

    @desc "Total number of followers, including those we can't see"
    field :follower_count, :integer do
      resolve(&FacetsResolvers.follower_count_edge/3)
    end

    @desc "Total number of likers, including those we can't see"
    field :liker_count, :integer do
      resolve(&FacetsResolvers.liker_count_edge/3)
    end

    @desc "Subscriptions users have to the circle"
    field :followers, :follows_page do
      arg(:limit, :integer)
      arg(:before, list_of(non_null(:cursor)))
      arg(:after, list_of(non_null(:cursor)))
      resolve(&FacetsResolvers.followers_edge/3)
    end

    @desc "Likes users have made of the circle"
    field :likers, :likes_page do
      arg(:limit, :integer)
      arg(:before, list_of(non_null(:cursor)))
      arg(:after, list_of(non_null(:cursor)))
      resolve(&FacetsResolvers.likers_edge/3)
    end

    @desc "Flags users have made about the circle, most recently created first"
    field :flags, :flags_page do
      arg(:limit, :integer)
      arg(:before, list_of(non_null(:cursor)))
      arg(:after, list_of(non_null(:cursor)))
      resolve(&FacetsResolvers.flags_edge/3)
    end

    # @desc "Tags users have applied to the resource, most recently created first"
    # field :taggings, :taggings_page do
    #   arg :limit, :integer
    #   arg :before, list_of(non_null(:cursor))
    #   arg :after, list_of(non_null(:cursor))
    #   resolve &CommonResolver.taggings_edge/3
    # end

    @desc """
    The threads created on the circle, most recently created
    first. Does not include threads created on resources.
    """
    field :threads, :threads_page do
      arg(:limit, :integer)
      arg(:before, list_of(non_null(:cursor)))
      arg(:after, list_of(non_null(:cursor)))
      resolve(&ThreadsResolver.threads_edge/3)
    end

    @desc "Activities on the circle, most recent first"
    field :outbox, :activities_page do
      arg(:limit, :integer)
      arg(:before, list_of(non_null(:cursor)))
      arg(:after, list_of(non_null(:cursor)))
      resolve(&FacetsResolvers.outbox_edge/3)
    end
  end

  object :circles_page do
    field(:page_info, non_null(:page_info))
    field(:edges, non_null(list_of(non_null(:circle))))
    field(:total_count, non_null(:integer))
  end

  input_object :circle_input do
    field(:preferred_username, :string)
    field(:name, non_null(:string))
    field(:summary, :string)
    # field :primary_language_id, :string
  end

  input_object :circle_update_input do
    field(:name, non_null(:string))
    field(:summary, :string)
    # field :primary_language_id, :string
  end
end
