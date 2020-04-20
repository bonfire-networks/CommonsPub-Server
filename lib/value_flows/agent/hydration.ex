defmodule ValueFlows.Agent.Hydration do

  def hydrate(blueprint) do
    %{
      agent: [
        resolve_type: &ValueFlows.Agent.GraphQL.agent_resolve_type/2
      ],
      # person: [
      #   is_type_of: &ValueFlows.Agent.GraphQL.person_is_type_of/2
      # ],
      # organization: [
      #   is_type_of: &ValueFlows.Agent.GraphQL.organization_is_type_of/2
      # ],
      agent_query: %{
        all_agents: [
          resolve: &ValueFlows.Agent.GraphQL.all_agents/3
        ],
        agent: [
          resolve: &ValueFlows.Agent.GraphQL.agent/2
        ],
        person: [
          resolve: &ValueFlows.Agent.GraphQL.user/2
        ],
        person2: [
          resolve: &MoodleNetWeb.GraphQL.UsersResolver.user/2
        ],
      },
      # mutation: %{
      #   failing_thing: [
      #     resolve: &__MODULE__.resolve_failing_thing/3
      #   ]
      # }
    }
  end




end