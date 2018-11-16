defmodule MoodleNet.Schema do
  use Absinthe.Schema
  import_types MoodleNet.Schema.Types

  # alias MoodleNet.Resolver

  query do

    # @desc "Get instance info"
    # field :instance, type :instance do
    #   resolve &MoodleNet.InstanceResolver.find/2
    # end

    @desc "Get all actors"
    field :all_actors, non_null(list_of(non_null(:actor))) do
      resolve &MoodleNet.UserResolver.all/2
    end

    @desc "Get an actor"
    field :actor, type: :actor do
      arg :id, non_null(:id)
      resolve &MoodleNet.UserResolver.find/2
    end

    @desc "Get my actor"
    field :my_actor, type: :actor do
      resolve &MoodleNet.UserResolver.profile/2
    end

  end
end
