# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
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

    field :upload_icon_types, non_null(list_of(non_null(:string)))
    field :upload_image_types, non_null(list_of(non_null(:string)))
    field :upload_resource_types, non_null(list_of(non_null(:string)))
    field :upload_max_bytes, non_null(:integer)

    @desc "A JSON document containing more info beyond the default fields"
    field :extra_info, :json
    
    field :featured_collections, :features_page do
      resolve &InstanceResolver.featured_collections/3
    end

    field :featured_communities, :features_page do
      resolve &InstanceResolver.featured_communities/3
    end
    @desc """
    A list of public activity on the local instance, most recent first
    """
    field :outbox, :activities_page do
      arg :limit, :integer
      arg :before, list_of(non_null(:cursor))
      arg :after, list_of(non_null(:cursor))
      resolve &InstanceResolver.outbox_edge/3
    end

  end

end
