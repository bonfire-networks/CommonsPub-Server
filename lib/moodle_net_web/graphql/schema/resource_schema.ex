# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNetWeb.GraphQL.ResourceSchema do
  @moduledoc """
  GraphQL resource fields, associations, queries and mutations.
  """
  use Absinthe.Schema.Notation

  alias MoodleNetWeb.GraphQL.MoodleNetSchema, as: Resolver
  alias MoodleNetWeb.GraphQL.ResourceResolver

  object :resource_queries do

    @desc "Get a resource"
    field :resource, :resource do
      arg(:local_id, non_null(:integer))
      resolve(Resolver.resolve_by_id_and_type("MoodleNet:EducationalResource"))
    end

  end

  object :resource_mutations do

    @desc "Create a resource"
    field :create_resource, type: :resource do
      arg(:collection_local_id, non_null(:integer))
      arg(:resource, non_null(:resource_input))
      resolve(&ResourceResolver.create/2)
    end

    @desc "Update a resource"
    field :update_resource, type: :resource do
      arg(:resource_local_id, non_null(:integer))
      arg(:resource, non_null(:resource_input))
      resolve(&ResourceResolver.update/2)
    end

    @desc "Delete a resource"
    field :delete_resource, type: :boolean do
      arg(:local_id, non_null(:integer))
      resolve(&ResourceResolver.delete/2)
    end

    @desc "Copy a resource"
    field :copy_resource, type: non_null(:resource) do
      arg(:resource_local_id, non_null(:integer))
      arg(:collection_local_id, non_null(:integer))
      resolve(&ResourceResolver.copy/2)
    end

    @desc "Like a resource"
    field :like_resource, type: :boolean do
      arg(:local_id, non_null(:integer))
      resolve(&ResourceResolver.like/2)
    end

    @desc "Undo a previous like to a resource"
    field :undo_like_resource, type: :boolean do
      arg(:local_id, non_null(:integer))
      resolve(&ResourceResolver.undo_like/2)
    end

    @desc "Flag a resource"
    field :flag_resource, type: :boolean do
      arg(:local_id, non_null(:integer))
      arg(:reason, non_null(:string))
      resolve(&ResourceResolver.flag/2)
    end

    @desc "Undo a previous flag to a resource"
    field :undo_flag_resource, type: :boolean do
      arg(:local_id, non_null(:integer))
      resolve(&ResourceResolver.undo_flag/2)
    end

  end

  object :resource do

    field(:id, :string)
    field(:local_id, :integer)
    field(:local, :boolean)
    field(:type, list_of(:string))

    field(:name, :string)
    field(:content, :string)
    field(:summary, :string)

    field(:icon, :string)

    field(:primary_language, :string)
    field(:url, :string)

    field(:creator, :user, do: resolve(Resolver.with_assoc(:attributed_to, single: true)))

    field(:collection, :collection,
      do: resolve(Resolver.with_assoc(:context, single: true))
    )

    field :likers, non_null(:resource_likers_connection) do
      arg(:limit, :integer)
      arg(:before, :integer)
      arg(:after, :integer)
      resolve(Resolver.with_connection(:resource_liker))
    end

    field :flags, non_null(:resource_flags_connection) do
      arg(:limit, :integer)
      arg(:before, :integer)
      arg(:after, :integer)
      resolve(Resolver.with_connection(:resource_flags))
    end

    field(:published, :string)
    field(:updated, :string)

    field(:same_as, :string)
    field(:in_language, list_of(non_null(:string)))
    field(:public_access, :boolean)
    field(:is_accesible_for_free, :boolean)
    field(:license, :string)
    field(:learning_resource_type, :string)
    field(:educational_use, list_of(non_null(:string)))
    field(:time_required, :integer)
    field(:typical_age_range, :string)
  end

  object :resource_likers_connection do
    field(:page_info, non_null(:page_info))
    field(:edges, list_of(:resource_likers_edge))
    field(:total_count, non_null(:integer))
  end

  object :resource_likers_edge do
    field(:cursor, non_null(:integer))
    field(:node, :user)
  end

  object :resource_flags_connection do
    field(:page_info, non_null(:page_info))
    field(:edges, list_of(:resource_flags_edge))
    field(:total_count, non_null(:integer))
  end

  object :resource_flags_edge do
    field(:cursor, non_null(:integer))
    field(:node, :user)
  end

  input_object :resource_input do
    field(:id, :string)
    field(:local_id, :integer)
    field(:local, :boolean)
    field(:type, list_of(:string))
    field(:name, :string)
    field(:content, :string)
    field(:summary, :string)
    field(:icon, :string)
    field(:primary_language, :string)
    field(:url, :string)
    field(:same_as, :string)
    field(:in_language, list_of(non_null(:string)))
    field(:public_access, :boolean)
    field(:is_accesible_for_free, :boolean)
    field(:license, :string)
    field(:learning_resource_type, :string)
    field(:educational_use, list_of(non_null(:string)))
    field(:time_required, :integer)
    field(:typical_age_range, :string)
  end

end
