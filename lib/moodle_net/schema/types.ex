defmodule MoodleNet.Schema.Types do
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
    field :nickname, :string
    field :icon, :string
    field :name, :string
    # field :email, :string
    field :summary, :string
    field :local, :boolean
    # field :follower_address, :string
  end
end
