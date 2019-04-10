defmodule MoodleNetWeb.GraphQL.ResourceSchema do
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
      resolve(&ResourceResolver.create_resource/2)
    end

    @desc "Update a resource"
    field :update_resource, type: :resource do
      arg(:resource_local_id, non_null(:integer))
      arg(:resource, non_null(:resource_input))
      resolve(&ResourceResolver.update_resource/2)
    end

    @desc "Delete a resource"
    field :delete_resource, type: :boolean do
      arg(:local_id, non_null(:integer))
      resolve(&ResourceResolver.delete_resource/2)
    end

    @desc "Copy a resource"
    field :copy_resource, type: non_null(:resource) do
      arg(:resource_local_id, non_null(:integer))
      arg(:collection_local_id, non_null(:integer))
      resolve(&ResourceResolver.copy_resource/2)
    end

    @desc "Like a resource"
    field :like_resource, type: :boolean do
      arg(:local_id, non_null(:integer))
      resolve(&ResourceResolver.like_resource/2)
    end

    @desc "Undo a previous like to a resource"
    field :undo_like_resource, type: :boolean do
      arg(:local_id, non_null(:integer))
      resolve(&ResourceResolver.undo_like_resource/2)
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

    field(:collection, non_null(:collection),
      do: resolve(Resolver.with_assoc(:context, single: true))
    )

    field :likers, non_null(:collection_likers_connection) do
      arg(:limit, :integer)
      arg(:before, :integer)
      arg(:after, :integer)
      resolve(Resolver.with_connection(:collection_liker))
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
    field(:edges, non_null(list_of(non_null(:resource_likers_edge))))
    field(:total_count, non_null(:integer))
  end

  object :resource_likers_edge do
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
