defmodule ValueFlows.Planning.Hydration do

  alias MoodleNetWeb.GraphQL.{
    ActorsResolver
  }

  def hydrate(blueprint) do
    %{
      planning_query: %{
        intent: [
          resolve: &ValueFlows.Planning.Intent.GraphQL.intent/2
        ],
        intents: [
          resolve: &ValueFlows.Planning.Intent.GraphQL.all_intents/2
        ]
      },
      planning_mutation: %{
        create_intent: [
          resolve: &ValueFlows.Planning.Intent.GraphQL.create_intent/2
        ]
      }
    }
  end

end
