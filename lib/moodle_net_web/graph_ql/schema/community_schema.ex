defmodule MoodleNetWeb.GraphQL.CommunitySchema do
  use Absinthe.Schema.Notation

  alias MoodleNetWeb.GraphQL.MoodleNetSchema, as: Resolver

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

    field :collections, non_null(:community_collections_connection) do
      arg(:limit, :integer)
      arg(:before, :integer)
      arg(:after, :integer)
      resolve(Resolver.with_connection(:community_collection))
    end

    field :threads, non_null(:community_threads_connection) do
      arg(:limit, :integer)
      arg(:before, :integer)
      arg(:after, :integer)
      resolve(Resolver.with_connection(:community_thread))
    end

    field :members, non_null(:community_members_connection) do
      arg(:limit, :integer)
      arg(:before, :integer)
      arg(:after, :integer)
      resolve(Resolver.with_connection(:community_member))
    end

    field(:published, :string)
    field(:updated, :string)

    field(:followed, non_null(:boolean), do: resolve(Resolver.with_bool_join(:follow)))
  end

  object :community_page do
    field(:page_info, non_null(:page_info))
    field(:nodes, non_null(list_of(non_null(:community))))
  end

  object :community_collections_connection do
    field(:page_info, non_null(:page_info))
    field(:edges, non_null(list_of(:community_collections_edge)))
    field(:total_count, non_null(:integer))
  end

  object :community_collections_edge do
    field(:cursor, non_null(:integer))
    field(:node, :collection)
  end

  object :community_threads_connection do
    field(:page_info, non_null(:page_info))
    field(:edges, non_null(list_of(:community_threads_edge)))
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

  input_object :community_input do
    field(:name, non_null(:string))
    field(:content, non_null(:string))
    field(:summary, non_null(:string))
    field(:preferred_username, non_null(:string))
    field(:icon, :string)
    field(:primary_language, :string)
  end
end
