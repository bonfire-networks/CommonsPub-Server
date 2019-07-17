# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNetWeb.GraphQL.CommentSchema do
  @moduledoc """
  GraphQL comment fields, associations, queries and mutations.
  """
  use Absinthe.Schema.Notation

  require ActivityPub.Guards, as: APG

  alias MoodleNetWeb.GraphQL.CommentResolver
  alias MoodleNetWeb.GraphQL.MoodleNetSchema, as: Resolver

  object :comment_queries do

    @desc "Get a comment"
    field :comment, :comment do
      arg(:local_id, non_null(:integer))
      resolve(Resolver.resolve_by_id_and_type("Note"))
    end

  end

  object :comment_mutations do

    @desc "Create a new thread"
    field :create_thread, type: :comment do
      arg(:context_local_id, non_null(:integer))
      arg(:comment, non_null(:comment_input))
      resolve(&CommentResolver.create_thread/2)
    end

    @desc "Create a reply"
    field :create_reply, type: :comment do
      arg(:in_reply_to_local_id, non_null(:integer))
      arg(:comment, non_null(:comment_input))
      resolve(&CommentResolver.create_reply/2)
    end

    @desc "Delete a comment"
    field :delete_comment, type: :boolean do
      arg(:local_id, non_null(:integer))
      resolve(&CommentResolver.delete/2)
    end

    @desc "Like a comment"
    field :like_comment, type: :boolean do
      arg(:local_id, non_null(:integer))
      resolve(&CommentResolver.like/2)
    end

    @desc "Undo a previous like to a comment"
    field :undo_like_comment, type: :boolean do
      arg(:local_id, non_null(:integer))
      resolve(&CommentResolver.undo_like/2)
    end

    @desc "Like a comment"
    field :flag_comment, type: :boolean do
      arg(:local_id, non_null(:integer))
      arg(:reason, non_null(:string))
      resolve(&CommentResolver.flag/2)
    end

    @desc "Undo a previous like to a comment"
    field :undo_flag_comment, type: :boolean do
      arg(:local_id, non_null(:integer))
      resolve(&CommentResolver.undo_flag/2)
    end

  end

  object :comment do
    field(:id, :string)
    field(:local_id, :integer)
    field(:local, :boolean)
    field(:type, list_of(:string))

    field(:content, :string)
    field(:published, :string)
    field(:updated, :string)

    field(:author, :user, do: resolve(Resolver.with_assoc(:attributed_to, single: true)))

    field(:in_reply_to, :comment, do: resolve(Resolver.with_assoc(:in_reply_to, single: true)))

    field :replies, :comment_replies_connection do
      arg(:limit, :integer)
      arg(:before, :integer)
      arg(:after, :integer)
      resolve(Resolver.with_connection(:comment_reply))
    end

    field :likers, :comment_likers_connection do
      arg(:limit, :integer)
      arg(:before, :integer)
      arg(:after, :integer)
      resolve(Resolver.with_connection(:comment_liker))
    end

    field :flags, :comment_flags_connection do
      arg(:limit, :integer)
      arg(:before, :integer)
      arg(:after, :integer)
      resolve(Resolver.with_connection(:comment_flags))
    end

    field(:context, :comment_context, do: resolve(Resolver.with_assoc(:context, single: true, preload_assoc_individually: true)))
  end

  union :comment_context do
    description("Where the comment resides")

    types([:collection, :community])

    resolve_type(fn
      e, _ when APG.has_type(e, "MoodleNet:Community") -> :community
      e, _ when APG.has_type(e, "MoodleNet:Collection") -> :collection
    end)
  end

  object :comment_replies_connection do
    field(:page_info, non_null(:page_info))
    field(:edges, list_of(:comment_replies_edge))
    field(:total_count, non_null(:integer))
  end

  object :comment_replies_edge do
    field(:cursor, non_null(:integer))
    field(:node, :comment)
  end

  object :comment_likers_connection do
    field(:page_info, non_null(:page_info))
    field(:edges, list_of(:comment_likers_edge))
    field(:total_count, non_null(:integer))
  end

  object :comment_likers_edge do
    field(:cursor, non_null(:integer))
    field(:node, :user)
  end

  object :comment_flags_connection do
    field(:page_info, non_null(:page_info))
    field(:edges, list_of(:comment_flags_edge))
    field(:total_count, non_null(:integer))
  end

  object :comment_flags_edge do
    field(:cursor, non_null(:integer))
    field(:node, :user)
  end

  input_object :comment_input do
    field(:content, non_null(:string))
  end


end
