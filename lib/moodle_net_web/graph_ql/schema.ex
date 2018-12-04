defmodule MoodleNetWeb.GraphQL.Schema do
  use Absinthe.Schema

  import_types(MoodleNetWeb.GraphQL.Schema.JSON)
  import_types(MoodleNetWeb.GraphQL.Schema.Accounts)
  import_types(MoodleNetWeb.GraphQL.MoodleNetSchema)

  alias MoodleNetWeb.GraphQL.Resolvers.MoodleNetResolver

  query do
    @desc "Get list of communities"
    field :communities, non_null(list_of(non_null(:community))) do
      resolve(&MoodleNetResolver.list_communities/2)
    end

    @desc "Get a community"
    field :community, :community do
      arg(:local_id, non_null(:integer))
      resolve(&MoodleNetResolver.get_community/2)
    end

    @desc "Get list of collections"
    field :collections, non_null(list_of(non_null(:collection))) do
      arg(:context, non_null(:integer))
      resolve(&MoodleNetResolver.list_collections/2)
    end

    @desc "Get a collection"
    field :collection, :collection do
      arg(:local_id, non_null(:integer))
      resolve(&MoodleNetResolver.get_collection/2)
    end

    @desc "Get list of resources"
    field :resources, non_null(list_of(non_null(:resource))) do
      arg(:context, non_null(:integer))
      resolve(&MoodleNetResolver.list_resources/2)
    end

    @desc "Get a resource"
    field :resource, :resource do
      arg(:local_id, non_null(:integer))
      resolve(&MoodleNetResolver.get_resource/2)
    end


    @desc "Get my user"
    field :me, type: :user do
      resolve(fn
        _, %{context: %{current_user: nil}} ->
          {:error, "You are not logged in"}

        _, %{context: %{current_user: current_user}} ->
          ret =
            ActivityPub.SQL.get_by_local_id(current_user.primary_actor_id)
            |> MoodleNetResolver.to_map()

          {:ok, ret}
      end)
    end
  end

  mutation do
    @desc "Create a user"
    field :user_create, type: :user do
      arg(:user, non_null(:user_input))
      resolve(fn _, args, _ ->
        with {:ok, %{actor: actor, user: user}} <- MoodleNet.Accounts.register_user(args.user),
             {:ok, token} <- MoodleNet.OAuth.create_token(user.id) do
          ret =
            actor
            |> MoodleNetResolver.to_map()
            |> Map.put(:token, token.hash)

          {:ok, ret}
        else
          {:error, _, %Ecto.Changeset{} = ch, _} ->
            error =
              %{fields: MoodleNetWeb.ChangesetView.translate_errors(ch)}
              |> Map.put(:message, "Validation errors")

            {:error, error}
        end
      end)
    end

    @desc "Login"
    field :login, type: :user do
      arg(:email, non_null(:string))
      arg(:password, non_null(:string))

      resolve(fn _, %{email: email, password: password}, _ ->
        with {:ok, user} <- MoodleNet.Accounts.authenticate_by_email_and_pass(email, password),
             {:ok, token} <- MoodleNet.OAuth.create_token(user.id) do
          ret =
            user.primary_actor_id
            |> ActivityPub.SQL.get_by_local_id()
            |> MoodleNetResolver.to_map()
            |> Map.put(:token, token.hash)

          {:ok, ret}
        else
          e ->
            {:error, "Invalid credentials"}
        end
      end)
    end
  end
end
