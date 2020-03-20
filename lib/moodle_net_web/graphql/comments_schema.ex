# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.CommentsSchema do
  use Absinthe.Schema.Notation
  alias MoodleNetWeb.GraphQL.{
    CommentsResolver,
    CommonResolver,
    FlagsResolver,
    LikesResolver,
    UsersResolver,
  }

  object :comments_queries do

    @desc "Get a comment by its id"
    field :comment, :comment do
      arg :comment_id, non_null(:string)
      resolve &CommentsResolver.comment/2
    end

  end

  object :comments_mutations do

    @desc "Reply to an existing comment in a thread"
    field :create_reply, :comment do
      arg :thread_id, non_null(:string)
      arg :in_reply_to_id, non_null(:string)
      arg :comment, non_null(:comment_input)
      resolve &CommentsResolver.create_reply/2
    end

    @desc "Modify a comment"
    field :update_comment, :comment do
      arg :comment_id, non_null(:string)
      arg :comment, non_null(:comment_input)
      resolve &CommentsResolver.update/2
    end

  end

  object :comment do
    @desc "An instance-local UUID identifying the thread"
    field :id, non_null(:string)
    @desc "A url for the user, may be to a remote instance"
    field :canonical_url, :string

    @desc "The id of the comment this one was a reply to"
    field :in_reply_to, :comment do
      resolve &CommentsResolver.in_reply_to_edge/3
    end
    @desc "The comment text"
    field :content, non_null(:string)

    @desc "Whether the comment is local to the instance"
    field :is_local, non_null(:boolean)
    @desc "Whether the comment is publically visible"
    field :is_public, non_null(:boolean) do
      resolve &CommonResolver.is_public_edge/3
    end
    @desc "Whether an comment admin has hidden the thread"
    field :is_hidden, non_null(:boolean) do
      resolve &CommonResolver.is_hidden_edge/3
    end

    @desc "When the comment was created"
    field :created_at, non_null(:string) do
      resolve &CommonResolver.created_at_edge/3
    end
    @desc "When the comment was last updated"
    field :updated_at, non_null(:string)

    @desc "The current user's like of this comment, if any"
    field :my_like, :like do
      resolve &LikesResolver.my_like_edge/3
    end

    @desc "The current user's flag of this comment, if any"
    field :my_flag, :flag do
      resolve &FlagsResolver.my_flag_edge/3
    end

    @desc "The user who created this comment"
    field :creator, :user do
      resolve &UsersResolver.creator_edge/3
    end

    @desc "The thread this comment is part of"
    field :thread, :thread do
      resolve &CommentsResolver.thread_edge/3
    end

    @desc "Total number of likers, including those we can't see"
    field :liker_count, :integer do
      resolve &LikesResolver.liker_count_edge/3
    end

    @desc "Users who like the comment, most recently liked first"
    field :likers, :likes_page do
      arg :limit, :integer
      arg :before, list_of(:cursor)
      arg :after, list_of(:cursor)
      resolve &LikesResolver.likers_edge/3
    end

    @desc "Flags users have made about the comment, most recently created first"
    field :flags, :flags_page do
      arg :limit, :integer
      arg :before, list_of(:cursor)
      arg :after, list_of(:cursor)
      resolve &FlagsResolver.flags_edge/3
    end

  end

  object :comments_page do
    field :page_info, :page_info
    field :edges, non_null(list_of(:comment))
    field :total_count, non_null(:integer)
  end

  input_object :comment_input do
    field :content, non_null(:string)
  end

end
