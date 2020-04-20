defmodule ValueFlows.GraphQL.Hydrations do

  alias MoodleNetWeb.GraphQL.{
    ActorsResolver
  }

  def hydrate(blueprint) do
    # one line per VF module
    ValueFlows.Util.Hydration.hydrate(blueprint)
    ValueFlows.Measurement.Hydration.hydrate(blueprint)
    ValueFlows.Agent.Hydration.hydrate(blueprint)
  end




end