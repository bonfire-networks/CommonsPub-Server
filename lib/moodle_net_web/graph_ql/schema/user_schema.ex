defmodule MoodleNetWeb.GraphQL.UserSchema do
  use Absinthe.Schema.Notation

  alias MoodleNetWeb.GraphQL.MoodleNetSchema, as: Resolver

  object :auth_payload do
    field(:token, :string)
    field(:me, :me)
  end

  object :me do
    field(:user, :user)
    field(:email, :string)
  end

  object :user do
    field(:id, :id)
    field(:local_id, :integer)
    field(:local, :boolean)
    field(:type, list_of(:string))
    field(:preferred_username, :string)
    field(:name, :string)
    field(:summary, :string)
    field(:location, :string)
    field(:icon, :string)
    field(:primary_language, :string)

    field :joined_communities, :user_joined_communities_connection do
      arg(:limit, :integer)
      arg(:before, :integer)
      arg(:after, :integer)
      resolve(Resolver.with_connection(:joined_communities))
    end

    field :following_collections, :user_following_collections_connection do
      arg(:limit, :integer)
      arg(:before, :integer)
      arg(:after, :integer)
      resolve(Resolver.with_connection(:following_collection))
    end

    field :comments, :user_created_comments_connection do
      arg(:limit, :integer)
      arg(:before, :integer)
      arg(:after, :integer)
      resolve(Resolver.with_connection(:user_comment))
    end
  end

  object :user_joined_communities_connection do
    field(:page_info, non_null(:page_info))
    field(:edges, non_null(list_of(non_null(:user_joined_communities_edge))))
    field(:total_count, non_null(:integer))
  end

  object :user_joined_communities_edge do
    field(:cursor, non_null(:integer))
    field(:node, :community)
  end

  object :user_following_collections_connection do
    field(:page_info, non_null(:page_info))
    field(:edges, non_null(list_of(non_null(:user_following_collections_edge))))
    field(:total_count, non_null(:integer))
  end

  object :user_following_collections_edge do
    field(:cursor, non_null(:integer))
    field(:node, :collection)
  end

  object :user_created_comments_connection do
    field(:page_info, non_null(:page_info))
    field(:edges, non_null(list_of(non_null(:user_created_comments_edge))))
    field(:total_count, non_null(:integer))
  end

  object :user_created_comments_edge do
    field(:cursor, non_null(:integer))
    field(:node, :comment)
  end

  input_object :registration_input do
    field(:email, non_null(:string))
    field(:password, non_null(:string))
    field(:preferred_username, non_null(:string))
    field(:name, :string)
    field(:summary, :string)
    field(:location, :string)
    field(:icon, :string)
    field(:primary_language, :string)
  end

  input_object :update_profile_input do
    field(:preferred_username, :string)
    field(:name, :string)
    field(:summary, :string)
    field(:primary_language, :string)
    field(:location, :string)
    field(:icon, :string)
  end

  input_object :login_input do
    field(:email, non_null(:string))
    field(:password, non_null(:string))
  end
end
