# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.CommonSchema do
  use Absinthe.Schema.Notation
  alias MoodleNet.Collections.Collection
  alias MoodleNet.Comments.{Comment,Thread}
  alias MoodleNet.Communities.Community
  alias MoodleNet.Resources.Resource
  alias MoodleNet.Users.User
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
      resolve &UsersResolver.user/3
    end

    @desc "The thing that is being followed"
    field :followed, :follow_context do
      resolve &CommonResolver.followed/3
    end
  end

  union :follow_context do
    description "A thing that can be followed"
    types [:collection, :community, :thread, :user]
    resolve_type fn
      %Collection{}, _ -> :collection
      %Community{},  _ -> :community
      %Thread{},     _ -> :thread
      %User{},       _ -> :user
    end
  end

  object :follows_edges do
    field :page_info, non_null(:page_info)
    field :nodes, list_of(:follows_edge)
    field :total_count, non_null(:integer)
  end

  object :follows_edge do
    field :cursor, non_null(:string)
    field :node, :follow
  end

  @desc "A report about objectionable content"
  object :flag do
    @desc "An instance-local UUID identifying the user"
    field :id, :string
    @desc "A url for the flag, may be to a remote instance"
    field :canonical_url, :string

    @desc "The reason for flagging"
    field :message, :string
    @desc "Is the flag considered dealt with by the instance moderator?"
    field :is_resolved, :boolean

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
    field :flagged, :flag_context do
      resolve &CommonResolver.flag_flagged/3
    end

    # @desc "An optional thread to discuss the flag"
    # field :thread, :liked do
    #   resolve &CommonResolver.like_liked/3
    # end
  end

  union :flag_context do
    description "A thing that can be flagged"
    types [:collection, :comment, :community, :resource, :user]
    resolve_type fn
      %Collection{}, _ -> :collection
      %Comment{},    _ -> :comment
      %Community{},  _ -> :community
      %Resource{},   _ -> :resource
      %User{},       _ -> :user
    end
  end
  
  object :flags_nodes do
    field :page_info, non_null(:page_info)
    field :nodes, list_of(:flag)
    field :total_count, non_null(:integer)
  end

  object :flags_edges do
    field :page_info, non_null(:page_info)
    field :edges, list_of(:flags_edge)
    field :total_count, non_null(:integer)
  end

  object :flags_edge do
    field :cursor, non_null(:string)
    field :node, :flag
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
      resolve &UsersResolver.user/3
    end

    @desc "The thing that is liked"
    field :liked, :like_context do
      resolve &CommonResolver.context/3
    end
  end

  union :like_context do
    description "A thing which can be liked"
    types [:collection, :comment, :resource, :user]
    resolve_type fn
      %Collection{}, _ -> :collection
      %Comment{},    _ -> :comment
      %Resource{},   _ -> :resource
      %User{},       _ -> :user
    end
  end

  object :likes_edges do
    field :page_info, non_null(:page_info)
    field :edges, list_of(:likes_edge)
    field :total_count, non_null(:integer)
  end

  object :likes_edge do
    field :cursor, non_null(:string)
    field :node, :like
  end

  @desc "A category is a grouping mechanism for tags"
  object :category do
    @desc "An instance-local UUID identifying the category"
    field :id, :string

    @desc "The name of the tag category"
    field :name, :string

    @desc "Whether the like is local to the instance"
    field :is_local, :boolean
    @desc "Whether the like is public"
    field :is_public, :boolean

    @desc "When the like was created"
    field :created_at, :string

    # @desc "The current user's follow of the category, if any"
    # field :my_follow, :follow do
    #   resolve &CommonResolver.my_follow/3
    # end

    @desc "The tags in the category, most recently created first"
    field :tags, :tags_edges do
      arg :limit, :integer
      arg :before, :string
      arg :after, :string
      resolve &CommonResolver.category_tags/3
    end

  end

  object :categories_edges do
    field :page_info, non_null(:page_info)
    field :edges, list_of(:categories_edge)
    field :total_count, non_null(:integer)
  end

  object :categories_edge do
    field :cursor, non_null(:string)
    field :node, :category
  end

  @desc "A tag is a general mechanism for semantic grouping"
  object :tag do
    @desc "An instance-local UUID identifying the tag"
    field :id, :string
    @desc "The name of the tag"
    field :name, :string

    @desc "Whether the like is local to the instance"
    field :is_local, :boolean
    @desc "Whether the like is public"
    field :is_public, :boolean

    @desc "When the like was created"
    field :created_at, :string

    @desc "The current user's follow of the tag, if any"
    field :my_follow, :follow do
      resolve &CommonResolver.my_follow/3
    end

    @desc "The category the tag belongs to"
    field :category, :category do
      resolve &CommonResolver.tag_category/3
    end

    @desc "Taggings from users, most recent first"
    field :tagged, :taggings_edges do
      resolve &CommonResolver.tag_tagged/3
    end
    
  end

  object :tags_nodes do
    field :page_info, non_null(:page_info)
    field :nodes, list_of(:tag)
    field :total_count, non_null(:integer)
  end

  object :tags_edges do
    field :page_info, non_null(:page_info)
    field :edges, list_of(:tags_edge)
    field :total_count, non_null(:integer)
  end

  object :tags_edge do
    field :cursor, non_null(:string)
    field :node, :tag
  end

  @desc "One of these is created when a user tags something"
  object :tagging do
    @desc "An instance-local UUID identifying the tagging"
    field :id, :string

    @desc "Whether the like is local to the instance"
    field :is_local, :boolean
    @desc "Whether the like is public"
    field :is_public, :boolean

    @desc "When the like was created"
    field :created_at, :string

    @desc "The user who tagged"
    field :tagger, :user do
      resolve &UsersResolver.user/3
    end

    @desc "The tag being used"
    field :tag, :tag do
      resolve &CommonResolver.tag/3
    end

    @desc "The tagged object"
    field :tagged, :tagging_context do
      resolve &CommonResolver.tagged/3
    end
  end

  union :tagging_context do
    description "A thing which can be tagged"
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

  object :taggings_edges do
    field :page_info, non_null(:page_info)
    field :edges, list_of(:taggings_edge)
    field :total_count, non_null(:integer)
  end

  object :taggings_edge do
    field :cursor, non_null(:string)
    field :node, :tagging
  end

  object :common_mutations do

    @desc "Flag a user, community, collection, resource or comment, returning a flag id"
    field :flag, type: :flag do
      arg :context_id, non_null(:string)
      arg :message, non_null(:string)
      resolve &CommonResolver.create_flag/2
    end

    @desc "Follow a community, collection or thread returning a follow id"
    field :follow, :follow do
      arg :context_id, non_null(:string)
      resolve &CommonResolver.create_follow/2
    end

    @desc "Like a comment, collection, or resource returning a like id"
    field :like, :like do
      arg :context_id, non_null(:string)
      resolve &CommonResolver.create_like/2
    end

    # @desc "Tag something, returning a tagging id"
    # field :tag, :tagging do
    #   arg :context_id, non_null(:string)
    #   arg :tag_id, non_null(:string)
    #   resolve &CommonResolver.create_tagging/2
    # end

    @desc "Delete more or less anything"
    field :delete, :boolean do
      arg :context_id, non_null(:string)
      resolve &CommonResolver.delete/2
    end

  end

end
