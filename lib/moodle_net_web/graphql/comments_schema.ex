# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.CommentsSchema do
  @moduledoc """
  GraphQL comment fields, associations, queries and mutations.
  """
  use Absinthe.Schema.Notation

  require ActivityPub.Guards, as: APG

  alias MoodleNetWeb.GraphQL.CommentsResolver
  alias MoodleNet.Communities.Community
  alias MoodleNet.Collections.Collection

  object :comments_queries do

    @desc "Get a thread"
    field :thread, :thread do
      arg :thread_id, non_null(:string)
      resolve &CommentsResolver.fetch/2
    end

    @desc "Get a comment"
    field :comment, :comment do
      arg :comment_id, non_null(:string)
      resolve &CommentsResolver.fetch/2
    end

  end

  object :comments_mutations do

    @desc "Create a new thread"
    field :create_thread, type: :thread do
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
    field :last_activity, :string

    @desc "The current user's follow of the community, if any"
    field :my_follow, :follow do
      resolve &CommonResolver.my_follow/3
    end

    @desc "The object the thread is attached to"
    field :context, :thread_context do
      resolve &CommentsResolver.thread_context/3
    end

    @desc "Comments in the thread, most recently created first"
    field :comments, :thread_comments_connection do
      arg :limit, :integer
      arg :before, :string
      arg :after,  :string
      resolve &CommentsResolver.thread_comments/3
    end

    @desc "Users following the collection, most recently followed first"
    field :followers, :thread_followers_connection do
      arg :limit, :integer
      arg :before, :string
      arg :after,  :string
      resolve &CommonResolver.followers/3
    end

  end
    
  object :thread_comments_connection do
    field :page_info, non_null(:page_info)
    field :edges, list_of(:thread_comments_edge)
    field :total_count, non_null(:integer)
  end

  object :thread_comments_edge do
    field :cursor, non_null(:string)
    field :node, :comment
  end

  object :thread_followers_connection do
    field :page_info, non_null(:page_info)
    field :edges, list_of(:thread_followers_edge)
    field :total_count, non_null(:integer)
  end

  object :thread_followers_edge do
    field :cursor, non_null(:string)
    field :node, :follow
  end

  object :comment do
    @desc "An instance-local UUID identifying the thread"
    field :id, :string

    @desc "The comment text"
    field :content, :string

    @desc "The id of the comment this one was a reply to"
    field :in_reply_to_id, :string

    @desc "The current user's like of this comment, if any"
    field :my_like, :like do
      resolve &CommonResolver.my_like/3
    end

    @desc "The user who created this comment"
    field :creator, :user do
      resolve &CommonResolver.creator/3
    end

    @desc "Users who like the comment, most recently liked first"
    field :likers, :comment_likers_connection do
      arg :limit, :integer
      arg :before, :string
      arg :after, :string
      resolve &CommonResolver.likers/3
    end

    @desc "Flags users have made about the comment, most recently created first"
    field :flags, :comment_flags_connection do
      arg :limit, :integer
      arg :before, :string
      arg :after, :string
      resolve &CommonResolver.flags/3
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

  object :comment_likers_connection do
    field :page_info, non_null(:page_info)
    field :edges, list_of(:comment_likers_edge)
    field :total_count, non_null(:integer)
  end

  object :comment_likers_edge do
    field :cursor, non_null(:string)
    field :node, :like
  end

  object :comment_flags_connection do
    field :page_info, non_null(:page_info)
    field :edges, list_of(:comment_flags_edge)
    field :total_count, non_null(:integer)
  end

  object :comment_flags_edge do
    field :cursor, non_null(:string)
    field :node, :flag
  end

  input_object :comment_input do
    field :content, non_null(:string)
  end

end
