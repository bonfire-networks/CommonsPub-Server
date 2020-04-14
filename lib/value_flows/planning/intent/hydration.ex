defmodule ValueFlows.Planning.Intent.Hydration do

  alias MoodleNetWeb.GraphQL.{
    ActorsResolver
  }

  def hydrate(blueprint) do
    %{
      intent_query: %{
        intent: [
          resolve: &ValueFlows.Intent.GraphQL.intent/2
        ],
        all_intents: [
          resolve: &ValueFlows.Intent.GraphQL.all_intents/3
        ]
      },
      intent_mutation: %{
        create_intent: [
          resolve: &ValueFlows.Intent.GraphQL.create_intent/2
        ]
      }
    }
  end

end
