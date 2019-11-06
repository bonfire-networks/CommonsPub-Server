# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.CommonSchema do
  @moduledoc """
  Common schemas fields. Node is not used.
  """
  use Absinthe.Schema.Notation
  alias MoodleNetWeb.GraphQL.CommonResolver

  interface :node do
    field(:id, non_null(:id))
    field(:name, :string)
  end

  object :page_info do
    field(:start_cursor, :string)
    field(:end_cursor, :string)
  end

  object :common_mutations do

    @desc "Flag a user, community, collection, resource or comment"
    field :flag, type: :boolean do
      arg :context_id, non_null(:string)
      arg :reason, non_null(:string)
      resolve &CommonResolver.flag/2
    end

    @desc "Undo flagging a user, community, collection, resource or comment"
    field :undo_flag, type: :boolean do
      arg :context_id, non_null(:string)
      resolve &CommonResolver.undo_flag/2
    end

    @desc "Follow a community, collection or thread"
    field :follow, type: :boolean do
      arg :context_id, non_null(:string)
      resolve &CommonResolver.follow/2
    end

    @desc "Undo following a community, collection or thread"
    field :undo_follow, type: :boolean do
      arg :context_id, non_null(:string)
      resolve &CommonResolver.undo_follow/2
    end

    @desc "Like a comment, collection, or resource"
    field :like, type: :boolean do
      arg :context_id, non_null(:string)
      resolve &CommonResolver.like/2
    end

    @desc "Undo liking a comment, collection or resource"
    field :undo_like, type: :boolean do
      arg :context_id, non_null(:string)
      resolve &CommonResolver.undo_like/2
    end

  end

end
