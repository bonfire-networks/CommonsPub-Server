defmodule MoodleNet.GraphQL.Schema.ActivityPub do
  use Absinthe.Schema.Notation

  object :activity do
    field :id, :id
    field :uri, :string
    field :icon, :string
    field :summary, :string
    # field :local, :boolean
  end
end
