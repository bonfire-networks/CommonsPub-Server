defmodule MoodleNetWeb.GraphQL.Schema.Accounts do
  use Absinthe.Schema.Notation

  # object :instance do
  #   field :uri, :string
  #   field :title, :string
  #   field :description, :string
  #   field :email, :string
  # end

  object :actor do
    field :id, :id
    field :uri, :string
    field :nickname, :string, description: "The prefered nickname / user name of this actor"
    field :icon, :string
    field :name, :string
    # field :email, :string
    field :summary, :string
    field :local, :boolean
    field :types, list_of(:string)
    field :user, :user
    field :json, :json
  end

  object :user do
    field :id, :id
    field :email, :string
    field :password, :string
    field :preferred_username, :string
    field :name, :json
    field :summary, :json
    field :role, :string
  end

  input_object :user_input do
    field :email, non_null(:string)
    field :password, non_null(:string)
    field :preferred_username, non_null(:string)
    field :name, :json
    field :summary, :json
    field :role, :string
  end

end
