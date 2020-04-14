defmodule ValueFlows.Hydrations do

  alias MoodleNetWeb.GraphQL.{
    ActorsResolver
  }

  def hydrate(blueprint) do

    # one line per VF module
    hb = ValueFlows.Util.Hydration.hydrate(blueprint) 
    hb = Map.merge(hb, ValueFlows.Agent.Hydration.hydrate(blueprint)) 
    hb = Map.merge(hb, ValueFlows.Measurement.Hydration.hydrate(blueprint)) 
    # |> ValueFlows.Planning.Intent.Hydration.hydrate(blueprint)
    hb
  end




end