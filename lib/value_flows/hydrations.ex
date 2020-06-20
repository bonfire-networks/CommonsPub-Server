defmodule ValueFlows.Hydrations do

  alias MoodleNetWeb.GraphQL.{
    ActorsResolver,
    CommonResolver,
  }

  alias MoodleNet.Users.User

  
  def hydrate() do

    agent_fields = %{
      canonical_url: [
        resolve: &ActorsResolver.canonical_url_edge/3
      ],
      display_username: [
        resolve: &ActorsResolver.display_username_edge/3
      ],
      image: [
        resolve: &UploadResolver.image_content_edge/3
      ],
      in_scope_of: [
        resolve: &CommonResolver.context_edge/3
      ],
    }

    %{
      # Type extensions
      uri: [
          parse: &ValueFlows.Util.GraphQL.parse_cool_scalar/1,
          serialize: &ValueFlows.Util.GraphQL.serialize_cool_scalar/1
      ],

      agent: [
        resolve_type: &__MODULE__.agent_resolve_type/2,
      ],
      accounting_scope: [
        resolve_type: &__MODULE__.resolve_context_type/2
      ],
      person: agent_fields,
      organization: agent_fields,
      # person: [
      #   is_type_of: &ValueFlows.Agent.GraphQL.person_is_type_of/2
      # ],
      # organization: [
      #   is_type_of: &ValueFlows.Agent.GraphQL.organization_is_type_of/2
      # ],

      intent: %{
        provider: [
          resolve: &ValueFlows.Planning.Intent.GraphQL.fetch_provider_edge/3
        ],
        receiver: [
          resolve: &ValueFlows.Planning.Intent.GraphQL.fetch_receiver_edge/3
        ],
        in_scope_of: [
          resolve: &CommonResolver.context_edge/3
        ],
      },

      # start Query resolvers
      query: %{
      
      # Agents:
        agents: [
          resolve: &ValueFlows.Agent.GraphQL.all_agents/2
        ],
        agent: [
          resolve: &ValueFlows.Agent.GraphQL.agent/2,
          
        ],
        person: [
          resolve: &ValueFlows.Agent.GraphQL.person/2
        ],
        people: [
          resolve: &ValueFlows.Agent.GraphQL.all_people/2
        ],
        organization: [
          resolve: &ValueFlows.Agent.GraphQL.organization/2
        ],
        organizations: [
          resolve: &ValueFlows.Agent.GraphQL.all_organizations/2
        ],

      # Knowledge
        action: [
          resolve: &ValueFlows.Knowledge.Action.GraphQL.action/2
        ],
        actions: [
          resolve: &ValueFlows.Knowledge.Action.GraphQL.all_actions/2
        ],

      # Planning
        intent: [
          resolve: &ValueFlows.Planning.Intent.GraphQL.intent/2
        ],
        intents: [
          resolve: &ValueFlows.Planning.Intent.GraphQL.all_intents/2
        ]

      }, # end Queries

      # start Mutation resolvers
      mutation: %{
        create_intent: [
          resolve: &ValueFlows.Planning.Intent.GraphQL.create_intent/2
        ],
        create_action: [
          resolve: &ValueFlows.Knowledge.Action.GraphQL.create_action/2
        ],
        update_intent: [
          resolve: &ValueFlows.Planning.Intent.GraphQL.update_intent/2
        ],
      }
    }
  end

   # support for interface type
   def agent_resolve_type(%{agent_type: :person}, _), do: :person
   def agent_resolve_type(%{agent_type: :organization}, _), do: :organization
   def agent_resolve_type(%{agent_type: nil}, _), do: :person
 
   # def person_is_type_of(_), do: true
   # def organization_is_type_of(_), do: true

  def resolve_context_type(%Organisation{}, _), do: :organisation
  def resolve_context_type(%User{}, _), do: :user
end
