defmodule MoodleNetWeb.GraphQL.Schema do
  use Absinthe.Schema

  alias MoodleNetWeb.GraphQL.{MoodleNetSchema, MiscSchema}
  import_types(MoodleNetWeb.GraphQL.Schema.JSON)
  import_types(MoodleNetWeb.GraphQL.MoodleNetSchema)
  import_types(MoodleNetWeb.GraphQL.MiscSchema)

  query do
    @desc "Get list of communities"
    field :communities, non_null(list_of(non_null(:community))) do
      resolve(&MoodleNetSchema.list_communities/2)
    end

    @desc "Get a community"
    field :community, :community do
      arg(:local_id, non_null(:integer))
      resolve(MoodleNetSchema.resolve_by_id_and_type("MoodleNet:Community"))
    end

    @desc "Get list of collections"
    field :collections, non_null(list_of(non_null(:collection))) do
      arg(:community_local_id, non_null(:integer))
      resolve(&MoodleNetSchema.list_collections/2)
    end

    @desc "Get a collection"
    field :collection, :collection do
      arg(:local_id, non_null(:integer))
      resolve(MoodleNetSchema.resolve_by_id_and_type("MoodleNet:Collection"))
    end

    @desc "Get list of resources"
    field :resources, non_null(list_of(non_null(:resource))) do
      arg(:collection_local_id, non_null(:integer))
      resolve(&MoodleNetSchema.list_resources/2)
    end

    @desc "Get a resource"
    field :resource, :resource do
      arg(:local_id, non_null(:integer))
      resolve(MoodleNetSchema.resolve_by_id_and_type("MoodleNet:EducationalResource"))
    end

    @desc "Get list of comments"
    field :comments, non_null(list_of(non_null(:comment))) do
      arg(:context_local_id, non_null(:integer))
      resolve(&MoodleNetSchema.list_comments/2)
    end

    @desc "Get list of replies"
    field :replies, non_null(list_of(non_null(:comment))) do
      arg(:in_reply_to_local_id, non_null(:integer))
      resolve(&MoodleNetSchema.list_replies/2)
    end

    @desc "Get a comment"
    field :comment, :comment do
      arg(:local_id, non_null(:integer))
      resolve(MoodleNetSchema.resolve_by_id_and_type("Note"))
    end

    @desc "Get my user"
    field :me, type: :me do
      resolve(&MoodleNetSchema.me/2)
    end
  end

  mutation do
    @desc "Create a community"
    field :create_community, type: :community do
      arg(:community, non_null(:community_input))
      resolve(&MoodleNetSchema.create_community/2)
    end

    @desc "Update a community"
    field :update_community, type: :community do
      arg(:community_local_id, non_null(:integer))
      arg(:community, non_null(:community_input))
      resolve(&MoodleNetSchema.update_community/2)
    end

    @desc "Delete a community"
    field :delete_community, type: :boolean do
      arg(:local_id, non_null(:integer))
      resolve(&MoodleNetSchema.delete_community/2)
    end

    @desc "Create a collection"
    field :create_collection, type: :collection do
      arg(:community_local_id, non_null(:integer))
      arg(:collection, non_null(:collection_input))
      resolve(&MoodleNetSchema.create_collection/2)
    end

    @desc "Update a collection"
    field :update_collection, type: :collection do
      arg(:collection_local_id, non_null(:integer))
      arg(:collection, non_null(:collection_input))
      resolve(&MoodleNetSchema.update_collection/2)
    end

    @desc "Delete a collection"
    field :delete_collection, type: :boolean do
      arg(:local_id, non_null(:integer))
      resolve(&MoodleNetSchema.delete_collection/2)
    end

    @desc "Create a resource"
    field :create_resource, type: :resource do
      arg(:collection_local_id, non_null(:integer))
      arg(:resource, non_null(:resource_input))
      resolve(&MoodleNetSchema.create_resource/2)
    end

    @desc "Update a resource"
    field :update_resource, type: :resource do
      arg(:resource_local_id, non_null(:integer))
      arg(:resource, non_null(:resource_input))
      resolve(&MoodleNetSchema.update_resource/2)
    end

    @desc "Delete a resource"
    field :delete_resource, type: :boolean do
      arg(:local_id, non_null(:integer))
      resolve(&MoodleNetSchema.delete_resource/2)
    end

    @desc "Copy a resource"
    field :copy_resource, type: non_null(:resource) do
      arg(:resource_local_id, non_null(:integer))
      arg(:collection_local_id, non_null(:integer))
      resolve(&MoodleNetSchema.copy_resource/2)
    end

    @desc "Create a new thread"
    field :create_thread, type: :comment do
      arg(:context_local_id, non_null(:integer))
      arg(:comment, non_null(:comment_input))
      resolve(&MoodleNetSchema.create_thread/2)
    end

    @desc "Create a reply"
    field :create_reply, type: :comment do
      arg(:in_reply_to_local_id, non_null(:integer))
      arg(:comment, non_null(:comment_input))
      resolve(&MoodleNetSchema.create_reply/2)
    end

    @desc "Delete a comment"
    field :delete_comment, type: :boolean do
      arg(:local_id, non_null(:integer))
      resolve(&MoodleNetSchema.delete_comment/2)
    end

    @desc "Create a user"
    field :create_user, type: :auth_payload do
      arg(:user, non_null(:registration_input))
      resolve(&MoodleNetSchema.create_user/2)
    end

    @desc "Update a profile"
    field :update_profile, type: :me do
      arg(:profile, non_null(:update_profile_input))
      resolve(&MoodleNetSchema.update_profile/2)
    end

    @desc "Delete a user"
    field :delete_user, type: :boolean do
      resolve(&MoodleNetSchema.delete_user/2)
    end

    @desc "Join a community"
    field :join_community, type: :boolean do
      arg(:community_local_id, non_null(:integer))
      resolve(&MoodleNetSchema.join_community/2)
    end

    @desc "Undo join a community"
    field :undo_join_community, type: :boolean do
      arg(:community_local_id, non_null(:integer))
      resolve(&MoodleNetSchema.undo_join_community/2)
    end

    @desc "Follow a collection"
    field :follow_collection, type: :boolean do
      arg(:collection_local_id, non_null(:integer))
      resolve(&MoodleNetSchema.follow_collection/2)
    end

    @desc "Undo follow a collection"
    field :undo_follow_collection, type: :boolean do
      arg(:collection_local_id, non_null(:integer))
      resolve(&MoodleNetSchema.undo_follow_collection/2)
    end

    @desc "Like a comment"
    field :like_comment, type: :boolean do
      arg(:local_id, non_null(:integer))
      resolve(&MoodleNetSchema.like_comment/2)
    end

    @desc "Like a resource"
    field :like_resource, type: :boolean do
      arg(:local_id, non_null(:integer))
      resolve(&MoodleNetSchema.like_resource/2)
    end

    @desc "Undo a previous like to a comment"
    field :undo_like_comment, type: :boolean do
      arg(:local_id, non_null(:integer))
      resolve(&MoodleNetSchema.undo_like_comment/2)
    end

    @desc "Undo a previous like to a resource"
    field :undo_like_resource, type: :boolean do
      arg(:local_id, non_null(:integer))
      resolve(&MoodleNetSchema.undo_like_resource/2)
    end

    @desc "Login"
    field :create_session, type: :auth_payload do
      arg(:email, non_null(:string))
      arg(:password, non_null(:string))
      resolve(&MoodleNetSchema.create_session/2)
    end

    @desc "Logout"
    field :delete_session, type: :boolean do
      resolve(&MoodleNetSchema.delete_session/2)
    end

    @desc "Reset password request"
    field :reset_password_request, type: :boolean do
      arg(:email, non_null(:string))
      resolve(&MoodleNetSchema.reset_password_request/2)
    end

    @desc "Reset password"
    field :reset_password, type: :boolean do
      arg(:token, non_null(:string))
      arg(:password, non_null(:string))
      resolve(&MoodleNetSchema.reset_password/2)
    end

    @desc "Confirm email"
    field :confirm_email, type: :boolean do
      arg(:token, non_null(:string))
      resolve(&MoodleNetSchema.confirm_email/2)
    end

    @desc "Fetch metadata from webpage"
    field :fetch_web_metadata, type: :web_metadata do
      arg(:url, non_null(:string))
      resolve(&MiscSchema.fetch_web_metadata/2)
    end
  end
end
