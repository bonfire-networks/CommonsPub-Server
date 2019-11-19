# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.CommonSchema do
  use Absinthe.Schema.Notation
  alias MoodleNet.Activities.Activity
  alias MoodleNet.Common.{Flag, Follow, Like}
  alias MoodleNet.Collections.Collection
  alias MoodleNet.Common.{Flag, Follow, Like}
  alias MoodleNet.Comments.{Comment,Thread}
  alias MoodleNet.Communities.Community
  alias MoodleNet.Resources.Resource
  alias MoodleNet.Users.User
  alias MoodleNetWeb.GraphQL.{
    CommonResolver,
    UsersResolver,
  }

  object :common_queries do
    field :flag, :flag do
      arg :flag_id, non_null(:string)
      resolve &CommonResolver.flag/2
    end
    field :follow, :follow do
      arg :follow_id, non_null(:string)
      resolve &CommonResolver.follow/2
    end
    field :like, :like do
      arg :like_id, non_null(:string)
      resolve &CommonResolver.like/2
    end
    # field :tag, :tag do
    #   arg :tag_id, non_null(:string)
    #   resolve &CommonResolver.tag/2
    # end
    # field :tag_category, :tag_category do
    #   arg :tag_category_id, non_null(:string)
    #   resolve &CommonResolver.tag_category/2
    # end
    # field :tagging, :tagging do
    #   arg :tagging_id, non_null(:string)
    #   resolve &CommonResolver.tagging/2
    # end
  end

  object :common_mutations do

    @desc "Flag a user, community, collection, resource or comment, returning a flag id"
    field :create_flag, :flag do
      arg :context_id, non_null(:string)
      arg :message, non_null(:string)
      resolve &CommonResolver.create_flag/2
    end

    @desc "Follow a community, collection or thread returning a follow id"
    field :create_follow, :follow do
      arg :context_id, non_null(:string)
      resolve &CommonResolver.create_follow/2
    end

    @desc "Like a comment, collection, or resource returning a like id"
    field :create_like, :like do
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
    field :delete, :delete_context do
     arg :context_id, non_null(:string)
      resolve &CommonResolver.delete/2
    end

  end

  @desc "Cursors for pagination"
  object :page_info do
    field :start_cursor, non_null(:string)
    field :end_cursor, non_null(:string)
  end

  union :delete_context do
    description "A thing that can be deleted"
    types [
      :activity, :collection, :comment, :community, :flag,
      :follow, :like, :resource, :thread, :user,
    ]
    resolve_type fn
      %Activity{},   _ -> :activity
      %Collection{}, _ -> :collection
      %Comment{},    _ -> :comment
      %Community{},  _ -> :community
      %Flag{},       _ -> :flag
      %Follow{},     _ -> :follow
      %Like{},       _ -> :like
      %Resource{},   _ -> :resource
      %Thread{},     _ -> :thread
      %User{},       _ -> :user
    end
  end

  @desc "A report about objectionable content"
  object :flag do
    @desc "An instance-local UUID identifying the user"
    field :id, non_null(:string)
    @desc "A url for the flag, may be to a remote instance"
    field :canonical_url, :string

    @desc "The reason for flagging"
    field :message, non_null(:string)
    @desc "Is the flag considered dealt with by the instance moderator?"
    field :is_resolved, non_null(:boolean) do
      resolve &CommonResolver.is_resolved/3
    end

    @desc "Whether the flag is local to the instance"
    field :is_local, non_null(:boolean)
    @desc "Whether the flag is public"
    # field :is_public, non_null(:boolean) do
    #   resolve &CommonResolver.is_public/3
    # end

    @desc "When the flag was created"
    field :created_at, non_null(:string)
    @desc "When the flag was updated"
    field :updated_at, non_null(:string)

    @desc "The user who flagged"
    field :creator, non_null(:user) do
      resolve &CommonResolver.creator/3
    end

    @desc "The thing that is being flagged"
    field :context, non_null(:flag_context) do
      resolve &CommonResolver.context/3
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
    field :page_info, :page_info
    field :nodes, non_null(list_of(:flag))
    field :total_count, non_null(:integer)
  end

  object :flags_edges do
    field :page_info, :page_info
    field :edges, non_null(list_of(:flags_edge))
    field :total_count, non_null(:integer)
  end

  object :flags_edge do
    field :cursor, non_null(:string)
    field :node, non_null(:flag)
  end

  @desc "A record that a user follows something"
  object :follow do
    @desc "An instance-local UUID identifying the user"
    field :id, non_null(:string)
    @desc "A url for the flag, may be to a remote instance"
    field :canonical_url, :string

    @desc "Whether the follow is local to the instance"
    field :is_local, non_null(:boolean)
    @desc "Whether the follow is public"
    field :is_public, non_null(:boolean) do
      resolve &CommonResolver.is_public/3
    end

    @desc "When the follow was created"
    field :created_at, non_null(:string)
    @desc "When the follow was last updated"
    field :updated_at, non_null(:string)

    @desc "The user who followed"
    field :creator, non_null(:user) do
      resolve &CommonResolver.creator/3
    end

    @desc "The thing that is being followed"
    field :context, non_null(:follow_context) do
      resolve &CommonResolver.context/3
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
    field :page_info, :page_info
    field :edges, non_null(list_of(:follows_edge))
    field :total_count, non_null(:integer)
  end

  object :follows_edge do
    field :cursor, non_null(:string)
    field :node, non_null(:follow)
  end

  @desc "A record that a user likes a thing"
  object :like do
    @desc "An instance-local UUID identifying the like"
    field :id, non_null(:string)
    @desc "A url for the like, may be to a remote instance"
    field :canonical_url, :string
    
    @desc "Whether the like is local to the instance"
    field :is_local, non_null(:boolean)
    @desc "Whether the like is public"
    field :is_public, non_null(:boolean) do
      resolve &CommonResolver.is_public/3
    end

    @desc "When the like was created"
    field :created_at, non_null(:string)
    @desc "When the like was last updated"
    field :updated_at, non_null(:string)

    @desc "The user who liked"
    field :creator, non_null(:user) do
      resolve &CommonResolver.creator/3
    end

    @desc "The thing that is liked"
    field :context, non_null(:like_context) do
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
    field :page_info, :page_info
    field :edges, non_null(list_of(:likes_edge))
    field :total_count, non_null(:integer)
  end

  object :likes_edge do
    field :cursor, non_null(:string)
    field :node, non_null(:like)
  end

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
  #   field :created_at, :string

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

  # object :tag_categories_edges do
  #   field :page_info, non_null(:page_info)
  #   field :edges, list_of(:tag_categories_edge)
  #   field :total_count, non_null(:integer)
  # end

  # object :tag_categories_edge do
  #   field :cursor, non_null(:string)
  #   field :node, :tag_category
  # end


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
  #   field :created_at, :string

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

  # object :tag_categories_edges do
  #   field :page_info, non_null(:page_info)
  #   field :edges, list_of(:tag_categories_edge)
  #   field :total_count, non_null(:integer)
  # end

  # object :tag_categories_edge do
  #   field :cursor, non_null(:string)
  #   field :node, :tag_category
  # end

end
