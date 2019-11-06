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

    @desc "Get a comment"
    field :comment, :comment do
      arg :comment_id, non_null(:string)
      resolve &CommentsResolver.fetch/2
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

    @desc "Delete a comment"
    field :delete_comment, type: :boolean do
      arg :comment_id, non_null(:string)
      resolve &CommentsResolver.delete/2
    end

  end

  object :thread do
    field :id, :string
    field :local, :boolean
    field :published, :string
    field :comments, :thread_comments_connection do
      resolve &CommentsResolver.thread_comments/3
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

  object :comment do
    field :id, :string
    field :local, :boolean

    field :content, :string
    field :published, :string
    field :updated, :string

    field :in_reply_to_id, :string

    field :author, :user do
      resolve &CommentsResolver.author/3
    end

    field :in_reply_to, :comment do
      resolve &CommentsResolver.in_reply_to/3
    end

    field :likers, :comment_likers_connection do
      arg :limit, :integer
      arg :before, :string
      arg :after, :string
      resolve &CommentsResolver.likers/3
    end

    field :flags, :comment_flags_connection do
      arg :limit, :integer
      arg :before, :string
      arg :after, :string
      resolve &CommentsResolver.flags/3
    end

    field :context, :comment_context do
      resolve &CommentsResolver.context/3
    end
  end

  union :comment_context do
    description "The thing the comment is about"
    types [:collection, :community]
    resolve_type fn
      %Community{}, _ -> :community
      %Collection{}, _ -> :collection
    end
  end

  object :comment_replies_connection do
    field :page_info, non_null(:page_info)
    field :edges, list_of(:comment_replies_edge)
    field :total_count, non_null(:integer)
  end

  object :comment_replies_edge do
    field :cursor, non_null(:integer)
    field :node, :comment
  end

  object :comment_likers_connection do
    field :page_info, non_null(:page_info)
    field :edges, list_of(:comment_likers_edge)
    field :total_count, non_null(:integer)
  end

  object :comment_likers_edge do
    field :cursor, non_null(:integer)
    field :node, :user
  end

  object :comment_flags_connection do
    field :page_info, non_null(:page_info)
    field :edges, list_of(:comment_flags_edge)
    field :total_count, non_null(:integer)
  end

  object :comment_flags_edge do
    field :cursor, non_null(:integer)
    field :node, :user
  end

  input_object :comment_input do
    field :content, non_null(:string)
  end

end
