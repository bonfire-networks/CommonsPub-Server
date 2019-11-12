# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.CommentsSchema do
  use Absinthe.Schema.Notation
  alias MoodleNetWeb.GraphQL.{
    CommentsResolver,
    CommonResolver,
  }
  alias MoodleNet.Communities.Community
  alias MoodleNet.Collections.Collection
  alias MoodleNet.Common.Flag
  alias MoodleNet.Resources.Resource

  object :comments_queries do

    @desc "Get a thread"
    field :thread, :thread do
      arg :thread_id, non_null(:string)
      resolve &CommentsResolver.thread/2
    end

    @desc "Get a comment"
    field :comment, :comment do
      arg :comment_id, non_null(:string)
      resolve &CommentsResolver.comment/2
    end

  end

  object :comments_mutations do

    @desc "Create a new thread"
    field :create_thread, type: :comment do
      arg :context_id, non_null(:string)
      arg :comment, non_null(:comment_input)
      resolve &CommentsResolver.create_thread/2
    end

    @desc "Create a reply"
    field :create_reply, type: :comment do
      arg :thread_id, non_null(:string)
      arg :in_reply_to_id, non_null(:string)
      arg :comment, non_null(:comment_input)
      resolve &CommentsResolver.create_reply/2
    end

    @desc "Edit a comment"
    field :edit_comment, type: :comment do
      arg :comment_id, non_null(:string)
      arg :comment, non_null(:comment_input)
      resolve &CommentsResolver.update/2
    end

  end

  @desc "A thread is essentially a list of comments"
  object :thread do
    @desc "An instance-local UUID identifying the thread"
    field :id, :string
    @desc "A url for the user, may be to a remote instance"
    field :canonical_url, :string

    @desc "Whether the thread is local to the instance"
    field :is_local, :boolean
    @desc "Whether the thread is publically visible"
    field :is_public, :boolean
    @desc "Whether an instance admin has hidden the thread"
    field :is_hidden, :boolean

    @desc "When the thread was created"
    field :created_at, :string
    @desc "When the thread was last updated"
    field :updated_at, :string
    @desc "The last time the thread or a comment on it was created or updated"
    field :last_activity, :string do
      resolve &CommentsResolver.last_activity/3
    end

    @desc "The current user's follow of the community, if any"
    field :my_follow, :follow do
      resolve &CommonResolver.my_follow/3
    end

    @desc "The object the thread is attached to"
    field :context, :thread_context do
      resolve &CommentsResolver.context/3
    end

    @desc "Comments in the thread, most recently created first"
    field :comments, :comments_edges do
      arg :limit, :integer
      arg :before, :string
      arg :after,  :string
      resolve &CommentsResolver.comments/3
    end

    @desc "Users following the collection, most recently followed first"
    field :followers, :follows_edges do
      arg :limit, :integer
      arg :before, :string
      arg :after,  :string
      resolve &CommonResolver.followers/3
    end

  end
    
  union :thread_context do
    description "The thing the comment is about"
    types [:collection, :community, :flag, :resource]
    resolve_type fn
      %Collection{}, _ -> :collection
      %Community{},  _ -> :community
      %Flag{},       _ -> :flag
      %Resource{},   _ -> :resource
    end
  end

  object :threads_nodes do
    field :page_info, non_null(:page_info)
    field :nodes, list_of(:thread)
    field :total_count, non_null(:integer)
  end

  object :threads_edges do
    field :page_info, non_null(:page_info)
    field :edges, list_of(:threads_edge)
    field :total_count, non_null(:integer)
  end

  object :threads_edge do
    field :cursor, non_null(:string)
    field :node, :thread
  end

  object :comment do
    @desc "An instance-local UUID identifying the thread"
    field :id, :string
    @desc "A url for the user, may be to a remote instance"
    field :canonical_url, :string

    @desc "The id of the comment this one was a reply to"
    field :in_reply_to_id, :string
    @desc "The comment text"
    field :content, :string

    @desc "Whether the comment is local to the instance"
    field :is_local, :boolean
    @desc "Whether the comment is publically visible"
    field :is_public, :boolean
    @desc "Whether an comment admin has hidden the thread"
    field :is_hidden, :boolean

    @desc "When the comment was created"
    field :created_at, :string
    @desc "When the comment was last updated"
    field :updated_at, :string

    @desc "The current user's like of this comment, if any"
    field :my_like, :like do
      resolve &CommonResolver.my_like/3
    end

    @desc "The user who created this comment"
    field :creator, :user do
      resolve &CommonResolver.creator/3
    end

    @desc "The thread this comment is part of"
    field :thread, :thread do
      resolve &CommentsResolver.fetch/3
    end

    @desc "Users who like the comment, most recently liked first"
    field :likes, :likes_edges do
      arg :limit, :integer
      arg :before, :string
      arg :after, :string
      resolve &CommonResolver.likes/3
    end

    @desc "Flags users have made about the comment, most recently created first"
    field :flags, :flags_edges do
      arg :limit, :integer
      arg :before, :string
      arg :after, :string
      resolve &CommonResolver.flags/3
    end

  end

  object :comments_nodes do
    field :page_info, non_null(:page_info)
    field :nodes, list_of(:comment)
    field :total_count, non_null(:integer)
  end

  object :comments_edges do
    field :page_info, non_null(:page_info)
    field :edges, list_of(:comments_edge)
    field :total_count, non_null(:integer)
  end

  object :comments_edge do
    field :cursor, non_null(:string)
    field :node, :comment
  end

  input_object :comment_input do
    field :content, non_null(:string)
  end

end
