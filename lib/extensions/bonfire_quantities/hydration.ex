defmodule Bonfire.Quantities.Hydration do

  alias CommonsPub.Web.GraphQL.CommonResolver

  def hydrate() do
    %{
      # unit_context: [
      #   resolve_type: &CommonResolver.resolve_context_type/2
      # ],
      unit: %{
        canonical_url: [
          resolve: &CommonsPub.Characters.GraphQL.Resolver.canonical_url_edge/3
        ],
        in_scope_of: [
          resolve: &CommonResolver.context_edge/3
        ]
      },
      measure: %{
        canonical_url: [
          resolve: &CommonsPub.Characters.GraphQL.Resolver.canonical_url_edge/3
        ],
        has_unit: [
          resolve: &Bonfire.Quantities.Measures.GraphQL.has_unit_edge/3
        ]
      },
      measurement_query: %{
        units: [
          resolve: &Bonfire.Quantities.Units.GraphQL.all_units/2
        ],
        units_pages: [
          resolve: &Bonfire.Quantities.Units.GraphQL.units/2
        ],
        unit: [
          resolve: &Bonfire.Quantities.Units.GraphQL.unit/2
        ],
        measures_pages: [
          resolve: &Bonfire.Quantities.Measures.GraphQL.measures_pages/2
        ],
        # all_measures: [
        #   resolve: &Bonfire.Quantities.Measures.GraphQL.all_measures/2
        # ],
        measure: [
          resolve: &Bonfire.Quantities.Measures.GraphQL.measure/2
        ]
      },
      measurement_mutation: %{
        create_unit: [
          resolve: &Bonfire.Quantities.Units.GraphQL.create_unit/2
        ],
        update_unit: [
          resolve: &Bonfire.Quantities.Units.GraphQL.update_unit/2
        ],
        delete_unit: [
          resolve: &Bonfire.Quantities.Units.GraphQL.delete_unit/2
        ]
      }
    }
  end
end
