# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNetWeb.GraphQL.CollectionSchema do
  use Absinthe.Schema.Notation

  alias MoodleNetWeb.GraphQL.MoodleNetSchema, as: Resolver
  alias MoodleNetWeb.GraphQL.CollectionResolver

  object :collection_queries do
    @desc "Get list of collections"
    field :collections, :collection_page do
      arg(:limit, :integer)
      arg(:before, :integer)
      arg(:after, :integer)
      resolve(&CollectionResolver.collection_list/2)
    end

    @desc "Get a collection"
    field :collection, :collection do
      arg(:local_id, non_null(:integer))
      resolve(Resolver.resolve_by_id_and_type("MoodleNet:Collection"))
    end
  end

  object :collection_mutations do
    @desc "Create a collection"
    field :create_collection, type: :collection do
      arg(:community_local_id, non_null(:integer))
      arg(:collection, non_null(:collection_input))
      resolve(&CollectionResolver.create_collection/2)
    end

    @desc "Update a collection"
    field :update_collection, type: :collection do
      arg(:collection_local_id, non_null(:integer))
      arg(:collection, non_null(:collection_input))
      resolve(&CollectionResolver.update_collection/2)
    end

    @desc "Delete a collection"
    field :delete_collection, type: :boolean do
      arg(:local_id, non_null(:integer))
      resolve(&CollectionResolver.delete_collection/2)
    end

    @desc "Follow a collection"
    field :follow_collection, type: :boolean do
      arg(:collection_local_id, non_null(:integer))
      resolve(&CollectionResolver.follow_collection/2)
    end

    @desc "Undo follow a collection"
    field :undo_follow_collection, type: :boolean do
      arg(:collection_local_id, non_null(:integer))
      resolve(&CollectionResolver.undo_follow_collection/2)
    end

    @desc "Like a collection"
    field :like_collection, type: :boolean do
      arg(:local_id, non_null(:integer))
      resolve(&CollectionResolver.like_collection/2)
    end

    @desc "Undo a previous like to a collection"
    field :undo_like_collection, type: :boolean do
      arg(:local_id, non_null(:integer))
      resolve(&CollectionResolver.undo_like_collection/2)
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

    field(:icon, :string)

    field(:primary_language, :string)

    field(:creator, :user, do: resolve(Resolver.with_assoc(:attributed_to, single: true)))

    field(:community, :community, do: resolve(Resolver.with_assoc(:context, single: true)))

    field :followers, :collection_followers_connection do
      arg(:limit, :integer)
      arg(:before, :integer)
      arg(:after, :integer)
      resolve(Resolver.with_connection(:collection_follower))
    end

    field :resources, :collection_resources_connection do
      arg(:limit, :integer)
      arg(:before, :integer)
      arg(:after, :integer)
      resolve(Resolver.with_connection(:collection_resource))
    end

    field :threads, :collection_threads_connection do
      arg(:limit, :integer)
      arg(:before, :integer)
      arg(:after, :integer)
      resolve(Resolver.with_connection(:collection_thread))
    end

    field :likers, :collection_likers_connection do
      arg(:limit, :integer)
      arg(:before, :integer)
      arg(:after, :integer)
      resolve(Resolver.with_connection(:collection_liker))
    end

    field :inbox, :collection_inbox_connection do
      arg(:limit, :integer)
      arg(:before, :integer)
      arg(:after, :integer)
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
