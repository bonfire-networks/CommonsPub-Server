defmodule ValueFlows.Agent.Hydration do

  def hydrate(blueprint) do
    %{
      agent_query: %{
        all_agents: [
          resolve: &ValueFlows.Agent.GraphQL.all_agents/3
        ],
        agent_query: [
          resolve: &ValueFlows.Agent.GraphQL.agent/2
        ]
      },
      # mutation: %{
      #   failing_thing: [
      #     resolve: &__MODULE__.resolve_failing_thing/3
      #   ]
      # }
    }
  end




end