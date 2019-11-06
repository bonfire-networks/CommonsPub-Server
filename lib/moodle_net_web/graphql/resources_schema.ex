# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.ResourcesSchema do
  @moduledoc """
  GraphQL resource fields, associations, queries and mutations.
  """
  use Absinthe.Schema.Notation

  alias MoodleNetWeb.GraphQL.ResourcesResolver

  object :resource_queries do

    @desc "Get a resource"
    field :resource, :resource do
      arg :resource_id, non_null(:string)
      resolve &ResourcesResolver.fetch/2
    end

  end

  object :resource_mutations do

    @desc "Create a resource"
    field :create_resource, type: :resource do
      arg :collection_id, non_null(:string)
      arg :resource, non_null(:resource_input)
      resolve &ResourcesResolver.create/2
    end

    @desc "Update a resource"
    field :update_resource, type: :resource do
      arg :resource_id, non_null(:string)
      arg :resource, non_null(:resource_input)
      resolve &ResourcesResolver.update/2
    end

    @desc "Delete a resource"
    field :delete_resource, type: :boolean do
      arg :resource_id, non_null(:string)
      resolve &ResourcesResolver.delete/2
    end

    @desc "Copy a resource"
    field :copy_resource, type: non_null(:resource) do
      arg :resource_id, non_null(:string)
      arg :collection_id, non_null(:string)
      resolve &ResourcesResolver.copy/2
    end

  end

  object :resource do

    field :id, :string
    field :local, :boolean

    field :name, :string
    field :content, :string
    field :summary, :string

    field :icon, :string
    field :primary_language, :language
    field :url, :string

    field :creator, :user do
      resolve &ResourcesResolver.creator/3
    end

    field :collection, :collection do
      resolve &ResourcesResolver.collection/3
    end

    field :likers, non_null(:resource_likers_connection) do
      arg :limit, :integer
      arg :before, :string
      arg :after, :string
      resolve &ResourcesResolver.likers/3
    end

    field :flags, non_null(:resource_flags_connection) do
      arg :limit, :integer
      arg :before, :string
      arg :after, :string
      resolve &ResourcesResolver.flags/3
    end

    field :published, :string
    field :updated, :string

    field :same_as, :string
    field :in_language, list_of(non_null(:string))
    field :public_access, :boolean
    field :is_accessible_for_free, :boolean
    field :license, :string
    field :learning_resource_type, :string
    field :educational_use, list_of(non_null(:string))
    field :time_required, :integer
    field :typical_age_range, :string
  end

  object :resource_likers_connection do
    field :page_info, non_null(:page_info)
    field :edges, list_of(:resource_likers_edge)
    field :total_count, non_null(:integer)
  end

  object :resource_likers_edge do
    field :cursor, non_null(:integer)
    field :node, :user
  end

  object :resource_flags_connection do
    field :page_info, non_null(:page_info)
    field :edges, list_of(:resource_flags_edge)
    field :total_count, non_null(:integer)
  end

  object :resource_flags_edge do
    field(:cursor, non_null(:integer))
    field(:node, :user)
  end

  input_object :resource_input do
    field :name, :string
    field :content, :string
    field :summary, :string
    field :icon, :string
    field :primary_language, :string
    field :url, :string
    field :public_access, :boolean
    field :is_accessible_for_free, :boolean
    field :license, :string
    field :learning_resource_type, :string
    field :educational_use, list_of(non_null(:string))
    field :time_required, :integer
    field :typical_age_range, :string
  end

end
