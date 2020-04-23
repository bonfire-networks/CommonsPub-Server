defmodule ValueFlows.Hydrations do

  alias MoodleNetWeb.GraphQL.{
    ActorsResolver
  }

  def hydrate(blueprint) do
    # if System.get_env("ENABLE_EXTENSION_VALUEFLOWS", "false") == "true" do #TODO: find a way to make the VF schema optional 

      # one line per VF module
      hb = ValueFlows.Util.Hydration.hydrate(blueprint) 
      hb = Map.merge(hb, ValueFlows.Agent.Hydration.hydrate(blueprint)) 
      hb = Map.merge(hb, ValueFlows.Knowledge.Hydration.hydrate(blueprint)) 
      hb = Map.merge(hb, ValueFlows.Planning.Hydration.hydrate(blueprint)) 
      hb

    # else 
    #   %{}
    # end
  end




end