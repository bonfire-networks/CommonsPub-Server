# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.CollectionsSchema do
  @moduledoc """
  GraphQL collection fields, associations, queries and mutations.
  """
  use Absinthe.Schema.Notation

  alias MoodleNetWeb.GraphQL.MoodleNetSchema, as: Resolver
  alias MoodleNetWeb.GraphQL.CollectionsResolver

  object :collection_queries do

    @desc "Get list of collections"
    field :collections, :collection_page do
      arg :limit, :integer
      arg :before, :string
      arg :after, :string
      resolve &CollectionsResolver.list/2
    end

    @desc "Get a collection"
    field :collection, :collection do
      arg :collection_id, non_null(:string)
      resolve &CollectionResolver.fetch/2
    end
  end

  object :collection_mutations do

    @desc "Create a collection"
    field :create_collection, type: :collection do
      arg :community_id, non_null(:string)
      arg :collection, non_null(:collection_input)
      resolve &CollectionsResolver.create/2
    end

    @desc "Update a collection"
    field :update_collection, type: :collection do
      arg :collection_id, non_null(:integer)
      arg :collection, non_null(:collection_input)
      resolve &CollectionsResolver.update/2
    end

    @desc "Delete a collection"
    field :delete_collection, type: :boolean do
      arg :local_id, non_null(:integer)
      resolve &CollectionsResolver.delete/2
    end

  end


  object :collection do
    field(:id, :string)
    field(:local_id, :integer)
    field(:local, :boolean)
    field(:type, list_of(:string))

    field(:name, :string)
    field(:content, :string)
    field(:summary, :string)

    field(:preferred_username, :string)

    field(:icon, :icon)

    field(:primary_language, :string)

    field(:creator, :user, do: resolve(Resolver.with_assoc(:attributed_to, single: true)))

    field(:community, :community, do: resolve(Resolver.with_assoc(:context, single: true)))

    field :followers, :collection_followers_connection do
      arg :limit, :integer
      arg :before, :string
      arg :after,  :string
      resolve &CommonResolver.followers/3
    end

    field :resources, :collection_resources_connection do
      arg(:limit, :integer)
      arg(:before, :string)
      arg(:after, :string)
      resolve(Resolver.with_connection(:collection_resource))
    end

    field :threads, :collection_threads_connection do
      arg(:limit, :integer)
      arg(:before, :string)
      arg(:after, :string)
      resolve(Resolver.with_connection(:collection_thread))
    end

    field :likers, :collection_likers_connection do
      arg(:limit, :integer)
      arg(:before, :string)
      arg(:after, :string)
      resolve(Resolver.with_connection(:collection_liker))
    end

    field :flags, :collection_flags_connection do
      arg(:limit, :integer)
      arg(:before, :string)
      arg(:after, :string)
      resolve(Resolver.with_connection(:collection_flags))
    end

    field :inbox, :collection_inbox_connection do
      arg(:limit, :integer)
      arg(:before, :string)
      arg(:after, :string)
      resolve(Resolver.with_connection(:collection_inbox))
    end

    field(:published, :string)
    field(:updated, :string)

    field(:followed, non_null(:boolean), do: resolve(Resolver.with_bool_join(:follow)))
  end

  object :collection_page do
    field(:page_info, non_null(:page_info))
    field(:nodes, list_of(:collection))
    field(:total_count, non_null(:integer))
  end

  object :collection_followers_connection do
    field(:page_info, non_null(:page_info))
    field(:edges, list_of(:collection_followers_edge))
    field(:total_count, non_null(:integer))
  end

  object :collection_followers_edge do
    field(:cursor, non_null(:integer))
    field(:node, :user)
  end

  object :collection_resources_connection do
    field(:page_info, non_null(:page_info))
    field(:edges, list_of(:collection_resources_edge))
    field(:total_count, non_null(:integer))
  end

  object :collection_resources_edge do
    field(:cursor, non_null(:integer))
    field(:node, :resource)
  end

  object :collection_threads_connection do
    field(:page_info, non_null(:page_info))
    field(:edges, list_of(:collection_threads_edge))
    field(:total_count, non_null(:integer))
  end

  object :collection_threads_edge do
    field(:cursor, non_null(:integer))
    field(:node, :comment)
  end

  object :collection_likers_connection do
    field(:page_info, non_null(:page_info))
    field(:edges, list_of(:collection_likers_edge))
    field(:total_count, non_null(:integer))
  end

  object :collection_likers_edge do
    field(:cursor, non_null(:integer))
    field(:node, :user)
  end

  object :collection_flags_connection do
    field(:page_info, non_null(:page_info))
    field(:edges, list_of(:collection_flags_edge))
    field(:total_count, non_null(:integer))
  end

  object :collection_flags_edge do
    field(:cursor, non_null(:integer))
    field(:node, :user)
    field(:reason, :string)
  end

  object :collection_inbox_connection do
    field(:page_info, non_null(:page_info))
    field(:edges, list_of(:collection_activities_edge))
    field(:total_count, non_null(:integer))
  end

  object :collection_activities_edge do
    field(:cursor, non_null(:integer))
    field(:node, :activity)
  end

  input_object :collection_input do
    field(:name, non_null(:string))
    field(:content, non_null(:string))
    field(:summary, non_null(:string))
    field(:preferred_username, non_null(:string))
    field(:icon, :string)
    field(:primary_language, :string)
  end

end
