# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.MoodleverseSchema do
  @moduledoc """
  GraphQL activity fields, associations, queries and mutations.
  """
  use Absinthe.Schema.Notation
  # alias MoodleNetWeb.GraphQL.MoodleverseResolver

  object :moodleverse_queries do

    # @desc "A logical object for the local instance"
    # field :moodleverse, :moodleverse do
    #   resolve &MoodleverseResolver.moodleverse/2
    # end

  end

  object :moodleverse do

    # @desc """
    # A list of public activity from all federated instances
    # """
    # field :outbox, :activities_page do
    #   arg :limit, :integer
    #   arg :before, :string
    #   arg :after, :string
    #   resolve &MoodleverseResolver.outbox/3
    # end

  end

end
