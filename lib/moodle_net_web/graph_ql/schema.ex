defmodule MoodleNetWeb.GraphQL.Schema do
  use Absinthe.Schema

  alias MoodleNetWeb.GraphQL.{
    MoodleNetSchema,
    MiscSchema,
    CommonSchema,
    UserSchema,
    CommunitySchema,
    CollectionSchema,
    ResourceSchema,
    CommentSchema,
    ActivitySchema
  }

  import_types(UserSchema)
  import_types(CommunitySchema)
  import_types(CollectionSchema)
  import_types(ResourceSchema)
  import_types(CommentSchema)
  import_types(ActivitySchema)

  import_types(MiscSchema)
  import_types(CommonSchema)

  query do
    import_fields(:user_queries)
    import_fields(:community_queries)
    import_fields(:collection_queries)
    import_fields(:resource_queries)

    @desc "Get a comment"
    field :comment, :comment do
      arg(:local_id, non_null(:integer))
      resolve(MoodleNetSchema.resolve_by_id_and_type("Note"))
    end

    @desc "Get local activity list"
    field :local_activities, type: non_null(:generic_activity_page) do
      arg(:limit, :integer)
      arg(:before, :integer)
      arg(:after, :integer)
      resolve(&ActivitySchema.local_activity_list/2)
    end
  end

  mutation do
    import_fields(:user_mutations)
    import_fields(:community_mutations)
    import_fields(:collection_mutations)
    import_fields(:resource_mutations)



    # Comment

    @desc "Create a new thread"
    field :create_thread, type: :comment do
      arg(:context_local_id, non_null(:integer))
      arg(:comment, non_null(:comment_input))
      resolve(&CommentSchema.create_thread/2)
    end

    @desc "Create a reply"
    field :create_reply, type: :comment do
      arg(:in_reply_to_local_id, non_null(:integer))
      arg(:comment, non_null(:comment_input))
      resolve(&CommentSchema.create_reply/2)
    end

    @desc "Delete a comment"
    field :delete_comment, type: :boolean do
      arg(:local_id, non_null(:integer))
      resolve(&CommentSchema.delete_comment/2)
    end

    @desc "Like a comment"
    field :like_comment, type: :boolean do
      arg(:local_id, non_null(:integer))
      resolve(&CommentSchema.like_comment/2)
    end

    @desc "Undo a previous like to a comment"
    field :undo_like_comment, type: :boolean do
      arg(:local_id, non_null(:integer))
      resolve(&CommentSchema.undo_like_comment/2)
    end

    @desc "Fetch metadata from webpage"
    field :fetch_web_metadata, type: :web_metadata do
      arg(:url, non_null(:string))
      resolve(&MiscSchema.fetch_web_metadata/2)
    end
  end
end
