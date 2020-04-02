defmodule ValueFlows.Measurement.Hydration do

  def hydrate(blueprint) do
    %{
      measurement_query: %{
        all_units: [
          resolve: &ValueFlows.Measurement.GraphQL.all_units/3
        ],
        unit: [
          resolve: &ValueFlows.Measurement.GraphQL.unit/2
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