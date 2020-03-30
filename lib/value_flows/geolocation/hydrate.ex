defmodule ValueFlows.Geolocation.Hydrate do
    require Logger

    @doc "Imports the contents of this module"
    defmacro __using__(_) do
        quote do
            import ValueFlows.Geolocation.Hydrate
        end
    end

    def hydrate(%{identifier: :spatial_things}, [%{identifier: :geolocation_query} | _]) do
      Logger.info("hydrating spatial_things")
       {:resolve, &ValueFlows.GraphQL.Geolocation.geolocations/2}
    end

end    