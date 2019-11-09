# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.CommonSchema do
  use Absinthe.Schema.Notation
  alias MoodleNetWeb.GraphQL.CommonResolver

  @desc "Cursors for pagination"
  object :page_info do
    field :start_cursor, :string
    field :end_cursor, :string
  end

  @desc "A record that a user follows something"
  object :follow do
    @desc "An instance-local UUID identifying the user"
    field :id, :string
    @desc "A url for the flag, may be to a remote instance"
    field :canonical_url, :string

    @desc "Whether the follow is local to the instance"
    field :is_local, :boolean
    @desc "Whether the follow is public"
    field :is_public, :boolean

    @desc "When the like was created"
    field :created_at, :string

    @desc "The user who followed"
    field :follower, :user do
      resolve &CommonResolver.follow_follower/3
    end

    @desc "The thing that is being followed"
    field :followed, :followed do
      resolve &CommonResolver.follow_followed/3
    end
  end

  union :followed do
    description "The thing a follow is about"
    types [:collection, :community, :thread, :user]
    resolve_type fn
      %Collection{}, _ -> :collection
      %Community{},  _ -> :community
      %Thread{},     _ -> :thread
      %User{},       _ -> :user
    end
  end

  @desc "A report about objectionable content"
  object :flag do
    @desc "An instance-local UUID identifying the user"
    field :id, :string
    @desc "A url for the flag, may be to a remote instance"
    field :canonical_url, :string

    @desc "The reason for flagging"
    field :reason, :string
    @desc "Is the flag considered dealt with by the instance moderator?"
    field :is_solved, :string

    @desc "Whether the flag is local to the instance"
    field :is_local, :boolean
    @desc "Whether the flag is public"
    field :is_public, :boolean

    @desc "When the flag was created"
    field :created_at, :string
    @desc "When the flag was updated"
    field :updated_at, :string

    @desc "The user who flagged"
    field :flagger, :user do
      resolve &CommonResolver.flag_flagger/3
    end

    @desc "The thing that is being flagged"
    field :flagged, :flagged do
      resolve &CommonResolver.flag_flagged/3
    end

    # @desc "An optional thread to discuss the flag"
    # field :thread, :liked do
    #   resolve &CommonResolver.like_liked/3
    # end
  end

  union :flagged do
    description "The thing a flag is about"
    types [:collection, :comment, :community, :resource, :user]
    resolve_type fn
      %Collection{}, _ -> :collection
      %Comment{},    _ -> :comment
      %Community{},  _ -> :community
      %Resource{},   _ -> :resource
      %User{},       _ -> :user
    end
  end
  
  @desc "A record that a user likes a thing"
  object :like do
    @desc "An instance-local UUID identifying the like"
    field :id, :string
    @desc "A url for the like, may be to a remote instance"
    field :canonical_url, :string
    
    @desc "Whether the like is local to the instance"
    field :is_local, :boolean
    @desc "Whether the like is public"
    field :is_public, :boolean

    @desc "When the like was created"
    field :created_at, :string

    @desc "The user who liked"
    field :liker, :user do
      resolve &CommonResolver.like_liker/3
    end

    @desc "The thing that is liked"
    field :liked, :liked do
      resolve &CommonResolver.like_liked/3
    end
  end

  union :liked do
    description "Something which can be liked"
    types [:collection, :comment, :resource, :user]
    resolve_type fn
      %Collection{}, _ -> :collection
      %Comment{},    _ -> :comment
      %Resource{},   _ -> :resource
      %User{},       _ -> :user
    end
  end

  @desc "A category is a grouping mechanism for tags"
  object :category do
    @desc "An instance-local UUID identifying the category"
    field :id, :string

    @desc "The name of the tag category"
    field :name, :string

    @desc "When the category was created"
    field :created_at, :string

    @desc "The current user's follow of the category, if any"
    field :my_follow, :follow do
      resolve &CommonResolver.my_follow/3
    end

    @desc "The tags in the category, most recently created first"
    field :tags, :category_tags_connection do
      arg :limit, :integer
      arg :before, :string
      arg :after, :string
      resolve &CommonResolver.category_tags/3
    end

  end

  object :category_tags_connection do
    field :page_info, non_null(:page_info)
    field :edges, list_of(:category_tags_edge)
    field :total_count, non_null(:integer)
  end

  object :category_tags_edge do
    field :cursor, non_null(:string)
    field :node, :tag
  end

  @desc "A tag is a general mechanism for semantic grouping"
  object :tag do
    @desc "An instance-local UUID identifying the tag"
    field :id, :string

    @desc "The name of the tag"
    field :name, :string

    @desc "When the flag was created"
    field :created_at, :string

    @desc "The current user's follow of the tag, if any"
    field :my_follow, :follow do
      resolve &CommonResolver.my_follow/3
    end

    @desc "The category the tag belongs to"
    field :category, :category do
      resolve &CommonResolver.tag_category/3
    end

    @desc "Things users have tagged with this tag, most recent tagging first"
    field :tagged, :tag_tagged_connection do
      resolve &CommonResolver.tag_tagged/3
    end
    
  end

  object :tag_tagged_connection do
    field :page_info, non_null(:page_info)
    field :edges, list_of(:tag_tagged_edge)
    field :total_count, non_null(:integer)
  end

  object :tag_tagged_edge do
    field :cursor, non_null(:string)
    field :node, :tagging
  end

  @desc "One of these is created when a user tags something"
  object :tagging do
    field :tagger, :user do
      resolve &CommonSchema.tagging_tagger/3
    end
    field :tagged, :tagged do
      resolve &CommonSchema.tagging_tagged/3
    end
  end

  union :tagged do
    description "Something which can be tagged"
    types [:collection, :comment, :community, :resource, :thread, :user]
    resolve_type fn
      %Collection{}, _ -> :collection
      %Comment{},    _ -> :comment
      %Community{},  _ -> :community
      %Resource{},   _ -> :resource
      %Thread{},     _ -> :thread
      %User{},       _ -> :user
    end
  end

  object :common_mutations do

    @desc "Flag a user, community, collection, resource or comment, returning a flag id"
    field :flag, type: :string do
      arg :context_id, non_null(:string)
      arg :reason, non_null(:string)
      resolve &CommonResolver.flag/2
    end

    @desc "Follow a community, collection or thread returning a follow id"
    field :follow, type: :string do
      arg :context_id, non_null(:string)
      resolve &CommonResolver.follow/2
    end

    @desc "Like a comment, collection, or resource returning a like id"
    field :like, type: :string do
      arg :context_id, non_null(:string)
      resolve &CommonResolver.like/2
    end

    @desc "Delete a thing, anything"
    field :delete, type: :boolean do
      arg :context_id, non_null(:string)
      resolve &CommonResolver.delete/2
    end

  end

end
