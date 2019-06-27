# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNetWeb.GraphQL.CommunitySchema do
  use Absinthe.Schema.Notation

  alias MoodleNetWeb.GraphQL.MoodleNetSchema, as: Resolver
  alias MoodleNetWeb.GraphQL.CommunityResolver

  object :community_queries do
    @desc "Get list of communities"
    field :communities, :community_page do
      arg(:limit, :integer)
      arg(:before, :integer)
      arg(:after, :integer)
      resolve(&CommunityResolver.community_list/2)
    end

    @desc "Get a community"
    field :community, :community do
      arg(:local_id, non_null(:integer))
      resolve(Resolver.resolve_by_id_and_type("MoodleNet:Community"))
    end
  end

  object :community_mutations do
    @desc "Create a community"
    field :create_community, type: :community do
      arg(:community, non_null(:community_input))
      resolve(&CommunityResolver.create_community/2)
    end

    @desc "Update a community"
    field :update_community, type: :community do
      arg(:community_local_id, non_null(:integer))
      arg(:community, non_null(:community_input))
      resolve(&CommunityResolver.update_community/2)
    end

    @desc "Delete a community"
    field :delete_community, type: :boolean do
      arg(:local_id, non_null(:integer))
      resolve(&CommunityResolver.delete_community/2)
    end

    @desc "Join a community"
    field :join_community, type: :boolean do
      arg(:community_local_id, non_null(:integer))
      resolve(&CommunityResolver.join_community/2)
    end

    @desc "Undo join a community"
    field :undo_join_community, type: :boolean do
      arg(:community_local_id, non_null(:integer))
      resolve(&CommunityResolver.undo_join_community/2)
    end
  end

  object :community do
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

    field :collections, :community_collections_connection do
      arg(:limit, :integer)
      arg(:before, :integer)
      arg(:after, :integer)
      resolve(Resolver.with_connection(:community_collection))
    end

    field :threads, :community_threads_connection do
      arg(:limit, :integer)
      arg(:before, :integer)
      arg(:after, :integer)
      resolve(Resolver.with_connection(:community_thread))
    end

    field :members, :community_members_connection do
      arg(:limit, :integer)
      arg(:before, :integer)
      arg(:after, :integer)
      resolve(Resolver.with_connection(:community_member))
    end

    field :inbox, :community_inbox_connection do
      arg(:limit, :integer)
      arg(:before, :integer)
      arg(:after, :integer)
      resolve(Resolver.with_connection(:community_inbox))
    end

    field(:published, :string)
    field(:updated, :string)

    field(:followed, non_null(:boolean), do: resolve(Resolver.with_bool_join(:follow)))
  end

  object :community_page do
    field(:page_info, non_null(:page_info))
    field(:nodes, list_of(:community))
    field(:total_count, non_null(:integer))
  end

  object :community_collections_connection do
    field(:page_info, non_null(:page_info))
    field(:edges, list_of(:community_collections_edge))
    field(:total_count, non_null(:integer))
  end

  object :community_collections_edge do
    field(:cursor, non_null(:integer))
    field(:node, :collection)
  end

  object :community_threads_connection do
    field(:page_info, non_null(:page_info))
    field(:edges, list_of(:community_threads_edge))
    field(:total_count, non_null(:integer))
  end

  object :community_threads_edge do
    field(:cursor, non_null(:integer))
    field(:node, :comment)
  end

  object :community_members_connection do
    field(:page_info, non_null(:page_info))
    field(:edges, list_of(:community_members_edge))
    field(:total_count, non_null(:integer))
  end

  object :community_members_edge do
    field(:cursor, non_null(:integer))
    field(:node, :user)
  end

  object :community_inbox_connection do
    field(:page_info, non_null(:page_info))
    field(:edges, list_of(:community_activities_edge))
    field(:total_count, non_null(:integer))
  end

  object :community_activities_edge do
    field(:cursor, non_null(:integer))
    field(:node, :activity)
  end

  input_object :community_input do
    field(:name, non_null(:string))
    field(:content, non_null(:string))
    field(:summary, non_null(:string))
    field(:preferred_username, non_null(:string))
    field(:icon, :string)
    field(:primary_language, :string)
  end
end
