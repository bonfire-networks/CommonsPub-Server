# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.CommentsSchema do
  use Absinthe.Schema.Notation
  alias MoodleNetWeb.GraphQL.{
    CommentsResolver,
    CommonResolver,
    UsersResolver,
  }
  alias MoodleNet.Communities.Community
  alias MoodleNet.Collections.Collection
  alias MoodleNet.Common.Flag
  alias MoodleNet.Resources.Resource

  object :comments_queries do

    @desc "Get a thread"
    field :thread, non_null(:thread) do
      arg :thread_id, non_null(:string)
      resolve &CommentsResolver.thread/2
    end

    @desc "Get a comment"
    field :comment, non_null(:comment) do
      arg :comment_id, non_null(:string)
      resolve &CommentsResolver.comment/2
    end

  end

  object :comments_mutations do

    @desc "Create a new thread"
    field :create_thread, non_null(:comment) do
      arg :context_id, non_null(:string)
      arg :comment, non_null(:comment_input)
      resolve &CommentsResolver.create_thread/2
    end

    @desc "Create a reply"
    field :create_reply, non_null(:comment) do
      arg :thread_id, non_null(:string)
      arg :in_reply_to_id, non_null(:string)
      arg :comment, non_null(:comment_input)
      resolve &CommentsResolver.create_reply/2
    end

    @desc "Edit a comment"
    field :edit_comment, non_null(:comment) do
      arg :comment_id, non_null(:string)
      arg :comment, non_null(:comment_input)
      resolve &CommentsResolver.update/2
    end

  end

  @desc "A thread is essentially a list of comments"
  object :thread do
    @desc "An instance-local UUID identifying the thread"
    field :id, non_null(:string)
    @desc "A url for the user, may be to a remote instance"
    field :canonical_url, :string

    @desc "Whether the thread is local to the instance"
    field :is_local, non_null(:boolean)
    @desc "Whether the thread is publically visible"
    field :is_public, non_null(:boolean)
    @desc "Whether an instance admin has hidden the thread"
    field :is_hidden, non_null(:boolean)

    @desc "When the thread was created"
    field :created_at, non_null(:string)
    @desc "When the thread was last updated"
    field :updated_at, non_null(:string)
    @desc "The last time the thread or a comment on it was created or updated"
    field :last_activity, non_null(:string) do
      resolve &CommentsResolver.last_activity/3
    end

    @desc "The current user's follow of the community, if any"
    field :my_follow, :follow do
      resolve &CommonResolver.my_follow/3
    end

    @desc "The object the thread is attached to"
    field :context, non_null(:thread_context) do
      resolve &CommentsResolver.context/3
    end

    @desc "Comments in the thread, most recently created first"
    field :comments, non_null(:comments_edges) do
      arg :limit, :integer
      arg :before, :string
      arg :after,  :string
      resolve &CommentsResolver.comments/3
    end

    @desc "Users following the collection, most recently followed first"
    field :followers, non_null(:follows_edges) do
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
    field :page_info, :page_info
    field :nodes, non_null(list_of(:thread))
    field :total_count, non_null(:integer)
  end

  object :threads_edges do
    field :page_info, :page_info
    field :edges, list_of(:threads_edge)
    field :total_count, non_null(:integer)
  end

  object :threads_edge do
    field :cursor, non_null(:string)
    field :node, non_null(:thread)
  end

  object :comment do
    @desc "An instance-local UUID identifying the thread"
    field :id, non_null(:string)
    @desc "A url for the user, may be to a remote instance"
    field :canonical_url, :string

    @desc "The id of the comment this one was a reply to"
    field :in_reply_to, :comment do
      resolve &CommentsResolver.comment/3
    end
    @desc "The comment text"
    field :content, non_null(:string)

    @desc "Whether the comment is local to the instance"
    field :is_local, non_null(:boolean)
    @desc "Whether the comment is publically visible"
    field :is_public, non_null(:boolean)
    @desc "Whether an comment admin has hidden the thread"
    field :is_hidden, non_null(:boolean)

    @desc "When the comment was created"
    field :created_at, non_null(:string)
    @desc "When the comment was last updated"
    field :updated_at, non_null(:string)

    @desc "The current user's like of this comment, if any"
    field :my_like, :like do
      resolve &CommonResolver.my_like/3
    end

    @desc "The user who created this comment"
    field :creator, non_null(:user) do
      resolve &UsersResolver.creator/3
    end

    @desc "The thread this comment is part of"
    field :thread, non_null(:thread) do
      resolve &CommentsResolver.thread/3
    end

    @desc "Users who like the comment, most recently liked first"
    field :likes, non_null(:likes_edges) do
      arg :limit, :integer
      arg :before, :string
      arg :after, :string
      resolve &CommonResolver.likes/3
    end

    @desc "Flags users have made about the comment, most recently created first"
    field :flags, non_null(:flags_edges) do
      arg :limit, :integer
      arg :before, :string
      arg :after, :string
      resolve &CommonResolver.flags/3
    end

  end

  object :comments_nodes do
    field :page_info, :page_info
    field :nodes, non_null(list_of(:comment))
    field :total_count, non_null(:integer)
  end

  object :comments_edges do
    field :page_info, :page_info
    field :edges, non_null(list_of(:comments_edge))
    field :total_count, non_null(:integer)
  end

  object :comments_edge do
    field :cursor, non_null(:string)
    field :node, non_null(:comment)
  end

  input_object :comment_input do
    field :content, non_null(:string)
  end

end
