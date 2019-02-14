defmodule MoodleNetWeb.GraphQL.CollectionSchema do
  use Absinthe.Schema.Notation

  alias MoodleNetWeb.GraphQL.MoodleNetSchema, as: Resolver

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

    field(:community, non_null(:community), do: resolve(Resolver.with_assoc(:attributed_to, single: true)))

    field :followers, non_null(:collection_followers_connection) do
      arg(:limit, :integer)
      arg(:before, :integer)
      arg(:after, :integer)
      resolve(Resolver.with_connection(:collection_follower))
    end

    field :resources, non_null(:collection_resources_connection) do
      arg(:limit, :integer)
      arg(:before, :integer)
      arg(:after, :integer)
      resolve(Resolver.with_connection(:collection_resource))
    end

    field :threads, non_null(:collection_threads_connection) do
      arg(:limit, :integer)
      arg(:before, :integer)
      arg(:after, :integer)
      resolve(Resolver.with_connection(:collection_thread))
    end

    field :likers, non_null(:collection_likers_connection) do
      arg(:limit, :integer)
      arg(:before, :integer)
      arg(:after, :integer)
      resolve(Resolver.with_connection(:collection_liker))
    end

    field(:published, :string)
    field(:updated, :string)

    field(:followed, non_null(:boolean), do: resolve(Resolver.with_bool_join(:follow)))
  end

  object :collection_page do
    field(:page_info, non_null(:page_info))
    field(:nodes, non_null(list_of(non_null(:collection))))
    field(:total_count, non_null(:integer))
  end

  object :collection_followers_connection do
    field(:page_info, non_null(:page_info))
    field(:edges, non_null(list_of(non_null(:collection_followers_edge))))
    field(:total_count, non_null(:integer))
  end

  object :collection_followers_edge do
    field(:cursor, non_null(:integer))
    field(:node, :user)
  end

  object :collection_resources_connection do
    field(:page_info, non_null(:page_info))
    field(:edges, non_null(list_of(non_null(:collection_resources_edge))))
    field(:total_count, non_null(:integer))
  end

  object :collection_resources_edge do
    field(:cursor, non_null(:integer))
    field(:node, :resource)
  end

  object :collection_threads_connection do
    field(:page_info, non_null(:page_info))
    field(:edges, non_null(list_of(non_null(:collection_threads_edge))))
    field(:total_count, non_null(:integer))
  end

  object :collection_threads_edge do
    field(:cursor, non_null(:integer))
    field(:node, :comment)
  end

  object :collection_likers_connection do
    field(:page_info, non_null(:page_info))
    field(:edges, non_null(list_of(non_null(:collection_likers_edge))))
    field(:total_count, non_null(:integer))
  end

  object :collection_likers_edge do
    field(:cursor, non_null(:integer))
    field(:node, :user)
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
