defmodule ValueFlows.Measurement.Hydration do

  def hydrate(blueprint) do
    %{
      measurement_query: %{
        units: [
          resolve: &ValueFlows.Measurement.Unit.GraphQL.units/2
        ],
        all_units: [
          resolve: &ValueFlows.Measurement.Unit.GraphQL.all_units/2
        ],
        unit: [
          resolve: &ValueFlows.Measurement.Unit.GraphQL.unit/2
        ]
      },
      measurement_mutation: %{
        create_unit: [
          resolve: &ValueFlows.Measurement.Unit.GraphQL.create_unit/2
        ]

      }
    }
  end




end