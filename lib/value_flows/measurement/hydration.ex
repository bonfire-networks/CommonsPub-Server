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
        ],
        measures: [
          resolve: &ValueFlows.Measurement.Measure.GraphQL.measures/2
        ],
        all_measures: [
          resolve: &ValueFlows.Measurement.Measure.GraphQL.all_measures/2
        ],
        measure: [
          resolve: &ValueFlows.Measurement.Measure.GraphQL.measure/2
        ]
      },
      measurement_mutation: %{
        create_unit: [
          resolve: &ValueFlows.Measurement.Unit.GraphQL.create_unit/2
        ],
        update_unit: [
          resolve: &ValueFlows.Measurement.Unit.GraphQL.update_unit/2
        ],
        create_measure: [
          resolve: &ValueFlows.Measurement.Measure.GraphQL.create_measure/2
        ],
        update_measure: [
          resolve: &ValueFlows.Measurement.Measure.GraphQL.update_measure/2
        ]

      }
    }
  end




end
