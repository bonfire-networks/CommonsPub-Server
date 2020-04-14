defmodule ValueFlows.Hydrations do

  alias MoodleNetWeb.GraphQL.{
    ActorsResolver
  }

  def hydrate(blueprint) do
    IO.inspect("hydrate VF")

    # one line per VF module
    ValueFlows.Util.Hydration.hydrate(blueprint)
    ValueFlows.Measurement.Hydration.hydrate(blueprint)
    ValueFlows.Agent.Hydration.hydrate(blueprint)
  end




end