defmodule Measurement.Hydration do

  def hydrate(blueprint) do
    %{
      measurement_query: %{
        units: [
          resolve: &Measurement.Unit.GraphQL.units/2
        ],
        units_pages: [
          resolve: &Measurement.Unit.GraphQL.all_units/2
        ],
        unit: [
          resolve: &Measurement.Unit.GraphQL.unit/2
        ],
        # measures: [
        #   resolve: &Measurement.Measure.GraphQL.measures/2
        # ],
        # all_measures: [
        #   resolve: &Measurement.Measure.GraphQL.all_measures/2
        # ],
        # measure: [
        #   resolve: &Measurement.Measure.GraphQL.measure/2
        # ]
      },
      measurement_mutation: %{
        create_unit: [
          resolve: &Measurement.Unit.GraphQL.create_unit/2
        ],
        update_unit: [
          resolve: &Measurement.Unit.GraphQL.update_unit/2
        ],
        # create_measure: [
        #   resolve: &Measurement.Measure.GraphQL.create_measure/2
        # ],
        # update_measure: [
        #   resolve: &Measurement.Measure.GraphQL.update_measure/2
        # ]

      }
    }
  end




end
