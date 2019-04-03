defmodule MoodleNetWeb.GraphQL.UserSchema do
  use Absinthe.Schema.Notation

  import MoodleNetWeb.GraphQL.MoodleNetSchema

  alias MoodleNetWeb.GraphQL.UserResolver

  object :user_queries do
    @desc "Get my user"
    field :me, type: :me do
      resolve(&UserResolver.me/2)
    end

    @desc "Get an user"
    field :user, type: :user do
      arg(:local_id, non_null(:integer))
      resolve(&UserResolver.user/2)
    end
  end

  object :user_mutations do
    @desc "Create a user"
    field :create_user, type: :auth_payload do
      arg(:user, non_null(:registration_input))
      resolve(&UserResolver.create_user/2)
    end

    @desc "Update a profile"
    field :update_profile, type: :me do
      arg(:profile, non_null(:update_profile_input))
      resolve(&UserResolver.update_profile/2)
    end

    @desc "Delete a user"
    field :delete_user, type: :boolean do
      resolve(&UserResolver.delete_user/2)
    end

    @desc "Reset password request"
    field :reset_password_request, type: :boolean do
      arg(:email, non_null(:string))
      resolve(&UserResolver.reset_password_request/2)
    end

    @desc "Reset password"
    field :reset_password, type: :boolean do
      arg(:token, non_null(:string))
      arg(:password, non_null(:string))
      resolve(&UserResolver.reset_password/2)
    end

    @desc "Confirm email"
    field :confirm_email, type: :boolean do
      arg(:token, non_null(:string))
      resolve(&UserResolver.confirm_email/2)
    end

    @desc "Login"
    field :create_session, type: :auth_payload do
      arg(:email, non_null(:string))
      arg(:password, non_null(:string))
      resolve(&UserResolver.create_session/2)
    end

    @desc "Logout"
    field :delete_session, type: :boolean do
      resolve(&UserResolver.delete_session/2)
    end
  end

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
      resolve(with_connection(:joined_communities))
    end

    field :following_collections, :user_following_collections_connection do
      arg(:limit, :integer)
      arg(:before, :integer)
      arg(:after, :integer)
      resolve(with_connection(:following_collection))
    end

    field :comments, :user_created_comments_connection do
      arg(:limit, :integer)
      arg(:before, :integer)
      arg(:after, :integer)
      resolve(with_connection(:user_comment))
    end

    field :inbox, non_null(:user_inbox_connection) do
      arg(:limit, :integer)
      arg(:before, :integer)
      arg(:after, :integer)
      resolve(with_connection(:user_inbox))
    end

    field :outbox, non_null(:user_outbox_connection) do
      arg(:limit, :integer)
      arg(:before, :integer)
      arg(:after, :integer)
      resolve(with_connection(:user_outbox))
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

  object :user_inbox_connection do
    field(:page_info, non_null(:page_info))
    field(:edges, list_of(:user_activities_edge))
    field(:total_count, non_null(:integer))
  end

  object :user_outbox_connection do
    field(:page_info, non_null(:page_info))
    field(:edges, list_of(:user_activities_edge))
    field(:total_count, non_null(:integer))
  end

  object :user_activities_edge do
    field(:cursor, non_null(:integer))
    field(:node, :activity)
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
