defmodule MoodleNetWeb.GraphQL.Schema do
  use Absinthe.Schema

  import_types(MoodleNetWeb.GraphQL.Schema.JSON)
  import_types(MoodleNetWeb.GraphQL.Schema.Accounts)
  import_types(MoodleNetWeb.GraphQL.Schema.Community)

  alias MoodleNetWeb.GraphQL.Resolvers

  query do
    @desc "Get list of communities"
    field :communities, non_null(list_of(non_null(:community))) do
      resolve(fn _, %{context: context} ->
        comms =
          MoodleNet.list_communities()
          |> Enum.map(fn comm ->
            collections = MoodleNet.list_collections(comm) |> Enum.map(&to_map/1)

            comm
            |> to_map()
            |> Map.put(:collections, collections)
          end)

        {:ok, comms}
      end)
    end

    @desc "Get list of collections"
    field :collections, non_null(list_of(non_null(:collection))) do
      arg(:parent_id, non_null(:id))
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

    @desc "Get my user"
    field :me, type: :user do
      resolve(fn
        _, %{context: %{current_user: nil}} ->
          {:error, "You are not logged in"}

        _, %{context: %{current_user: current_user}} ->
          ret =
            ActivityPub.get_by_local_id(current_user.primary_actor_id)
            |> to_map()

          {:ok, ret}
      end)
    end
  end

  mutation do
    @desc "Create a user"
    field :user_create, type: :user do
      arg(:user, non_null(:user_input))
      # resolve &Resolvers.Accounts.user_create/3
      resolve(fn _, args, _ ->
        with {:ok, %{actor: actor, user: user}} <- MoodleNet.Accounts.register_user(args.user),
             {:ok, token} <- MoodleNet.OAuth.create_token(user.id) do
          ret =
            actor
            |> to_map()
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
            |> to_map()
            |> Map.put(:token, token.hash)

          {:ok, ret}
        else
          e ->
            IO.inspect(e)
            {:error, "Invalid credentials"}
        end
      end)
    end
  end

  def to_map(comm) do
    %{
      id: comm[:id],
      local_id: comm[:local_id],
      local: comm[:local],
      type: comm[:type],
      name: from_language_value(comm[:name]),
      content: from_language_value(comm[:content]),
      summary: from_language_value(comm[:summary]),
      preferred_username: comm[:preferred_username],
      following_count: comm[:following_count],
      followers_count: comm[:followers_count],
      json_data: comm.extension_fields,
      icon: nil,
      primary_language: comm[:primary_language],
      location: comm[:location],
      email: comm[:email]
    }
  end

  def from_language_value(string) when is_binary(string), do: string
  def from_language_value(%{"und" => value}), do: value
  def from_language_value(%{}), do: nil
end
