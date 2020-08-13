defmodule Measurement.Hydration do
  alias MoodleNet.Communities.Community
  alias MoodleNet.Collections.Collection
  alias MoodleNetWeb.GraphQL.CommonResolver

  alias Organisation

  def hydrate() do
    %{
      # unit_context: [
      #   resolve_type: &CommonResolver.resolve_context_type/2
      # ],
      unit: %{
        in_scope_of: [
          resolve: &CommonResolver.context_edge/3
        ]
      },
      measure: %{
        has_unit: [
          resolve: &Measurement.Measure.GraphQL.has_unit_edge/3
        ]
      },
      measurement_query: %{
        units: [
          resolve: &Measurement.Unit.GraphQL.all_units/2
        ],
        units_pages: [
          resolve: &Measurement.Unit.GraphQL.units/2
        ],
        unit: [
          resolve: &Measurement.Unit.GraphQL.unit/2
        ],
        measures: [
          resolve: &Measurement.Measure.GraphQL.measures/2
        ],
        # all_measures: [
        #   resolve: &Measurement.Measure.GraphQL.all_measures/2
        # ],
        measure: [
          resolve: &Measurement.Measure.GraphQL.measure/2
        ]
      },
      measurement_mutation: %{
        create_unit: [
          resolve: &Measurement.Unit.GraphQL.create_unit/2
        ],
        update_unit: [
          resolve: &Measurement.Unit.GraphQL.update_unit/2
        ],
        delete_unit: [
          resolve: &Measurement.Unit.GraphQL.delete_unit/2
        ]
      }
    }
  end
end
