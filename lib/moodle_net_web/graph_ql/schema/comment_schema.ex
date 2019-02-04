defmodule MoodleNetWeb.GraphQL.CommentSchema do
  use Absinthe.Schema.Notation

  require ActivityPub.Guards, as: APG
  alias MoodleNetWeb.GraphQL.MoodleNetSchema, as: Resolver

  object :comment do
    field(:id, :string)
    field(:local_id, :integer)
    field(:local, :boolean)
    field(:type, list_of(:string))

    field(:content, :string)
    field(:likes_count, :integer)
    field(:replies_count, :integer)
    field(:published, :string)
    field(:updated, :string)

    field(:author, :user, do: resolve(Resolver.with_assoc(:attributed_to, single: true)))

    field(:in_reply_to, :comment, do: resolve(Resolver.with_assoc(:in_reply_to, single: true)))

    field :replies, non_null(:collection_replies_connection) do
      arg(:limit, :integer)
      arg(:before, :integer)
      arg(:after, :integer)
      resolve(Resolver.with_connection(:comment_reply))
    end

    field :likers, non_null(:collection_likers_connection) do
      arg(:limit, :integer)
      arg(:before, :integer)
      arg(:after, :integer)
      resolve(Resolver.with_connection(:collection_liker))
    end

    field(:context, :comment_context, do: resolve(Resolver.with_assoc(:context, single: true)))
  end

  union :comment_context do
    description("Where the comment resides")

    types([:collection, :community])

    resolve_type(fn
      e, _ when APG.has_type(e, "MoodleNet:Community") -> :community
      e, _ when APG.has_type(e, "MoodleNet:Collection") -> :collection
    end)
  end

  object :collection_replies_connection do
    field(:page_info, non_null(:page_info))
    field(:edges, non_null(list_of(non_null(:collection_replies_edge))))
    field(:total_count, non_null(:integer))
  end

  object :collection_replies_edge do
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

  input_object :comment_input do
    field(:content, non_null(:string))
  end

end
