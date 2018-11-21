defmodule MoodleNetWeb.GraphQL.Schema do
  use Absinthe.Schema

  import_types(MoodleNetWeb.GraphQL.Schema.JSON)
  import_types(MoodleNetWeb.GraphQL.Schema.Accounts)
  import_types(MoodleNetWeb.GraphQL.Schema.Community)

  alias MoodleNetWeb.GraphQL.Resolvers

  query do
    @desc "Get list of communities"
    field :communities, non_null(list_of(non_null(:community))) do
      resolve(fn _, _ ->
        comms =
          MoodleNet.list_communities()
          |> Enum.map(fn comm ->
            IO.inspect(comm)
            %{
              id: comm[:id],
              local_id: comm[:local_id],
              local: comm[:local],
              type: comm[:type],
              name: comm[:name],
              content: comm[:content],
              summary: comm[:summary],
              preferred_username: comm[:preferred_username],
              following_count: comm[:following_count],
              followers_count: comm[:followers_count],
              jsonData: comm.extension_fields,
              icon: nil,
              primary_language: comm[:primary_language]
            }
          end)

        {:ok, comms}
      end)
    end

    # @desc "Get instance info"
    # field :instance, type :instance do
    #   resolve &MoodleNet.InstanceResolver.find/2
    # end

    # @desc "Get all actors"
    # field :actors, non_null(list_of(non_null(:actor))) do
    #   resolve &Resolvers.Accounts.actors/3
    # end

    # @desc "Get an actor"
    # field :actor, type: :actor do
    #   arg :id, non_null(:id)
    #   resolve &Resolvers.Accounts.actor/3
    # end

    # @desc "Get my actor"
    # field :current_actor, type: :actor do
    #   resolve fn _, %{context: %{current_user: current_user}} ->
    #     {:ok, Resolvers.Accounts.actor_by_id(current_user.primary_actor_id) }
    #   end
    # end

    # @desc "Get my user"
    # field :current_user, type: :user do
    #   resolve fn _, %{context: %{current_user: current_user}} ->
    #     Resolvers.Accounts.current_user(current_user)
    #   end
    # end
  end
end
