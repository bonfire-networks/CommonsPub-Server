defmodule ValueFlows.Util.Hydration do

    def hydrate(blueprint) do
      %{
        uri: [
            parse: &ValueFlows.Util.GraphQL.parse_cool_scalar/1,
            serialize: &ValueFlows.Util.GraphQL.serialize_cool_scalar/1
        ]
      }
    end
  
  end