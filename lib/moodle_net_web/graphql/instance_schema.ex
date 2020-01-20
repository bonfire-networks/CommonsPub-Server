# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.InstanceSchema do
  @moduledoc """
  GraphQL activity fields, associations, queries and mutations.
  """
  use Absinthe.Schema.Notation
  alias MoodleNetWeb.GraphQL.InstanceResolver

  object :instance_queries do

    @desc "A logical object for the local instance"
    field :instance, :instance do
      resolve &InstanceResolver.instance/2
    end

  end

  object :instance do

    field :hostname, non_null(:string)
    # field :name, :string
    field :description, :string
    
    field :featured_collections, non_null(:features_edges) do
      resolve &InstanceResolver.featured_collections/3
    end

    field :featured_communities, non_null(:features_edges) do
      resolve &InstanceResolver.featured_communities/3
    end
    @desc """
    A list of public activity on the local instance, most recent first
    """
    field :outbox, non_null(:activities_edges) do
      arg :limit, :integer
      arg :before, :string
      arg :after, :string
      resolve &InstanceResolver.outbox_edge/3
    end

  end

end
